-- 02_triggers.sql — regras de negócio (executar após 01_ddl.sql)
USE hd_drones;
DELIMITER $$

-- RF06: recalcula valor_total e lucro_total da venda
CREATE PROCEDURE sp_recalcular_venda(IN p_id_venda INT UNSIGNED)
BEGIN
  DECLARE v_itens DECIMAL(12,2);
  DECLARE v_custos DECIMAL(12,2);
  DECLARE v_mao DECIMAL(12,2);
  SELECT COALESCE(SUM(quantidade * preco_unitario_aplicado), 0),
         COALESCE(SUM(quantidade * preco_custo_aplicado), 0)
    INTO v_itens, v_custos
    FROM item_venda WHERE id_venda = p_id_venda;
  SELECT COALESCE(SUM(valor_mao_obra), 0) INTO v_mao
    FROM ordem_servico WHERE id_venda = p_id_venda;
  UPDATE venda
     SET valor_total = v_itens + v_mao,
         lucro_total = v_itens + v_mao - v_custos
   WHERE id_venda = p_id_venda;
END$$

-- RN02 e RN04: valida estoque e congela o custo do produto
CREATE TRIGGER trg_item_venda_bi BEFORE INSERT ON item_venda
FOR EACH ROW
BEGIN
  DECLARE v_status VARCHAR(15);
  DECLARE v_custo DECIMAL(10,2);
  DECLARE v_estoque INT;
  SELECT status INTO v_status FROM venda WHERE id_venda = NEW.id_venda;
  IF v_status = 'Cancelada' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venda cancelada não aceita itens';
  END IF;
  SELECT preco_custo, quantidade_estoque INTO v_custo, v_estoque
    FROM produto WHERE id_produto = NEW.id_produto;
  IF v_estoque < NEW.quantidade THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN04: estoque insuficiente para o produto';
  END IF;
  SET NEW.preco_custo_aplicado = v_custo;
END$$

-- RF04: baixa automática gera movimentação; RF06: recalcula totais
CREATE TRIGGER trg_item_venda_ai AFTER INSERT ON item_venda
FOR EACH ROW
BEGIN
  INSERT INTO movimentacao_estoque
    (id_produto, id_funcionario, id_venda, quantidade_mov, tipo_movimentacao, data_movimentacao, observacao)
  SELECT NEW.id_produto, v.id_funcionario, v.id_venda, NEW.quantidade,
         IF(v.tipo = 'Ordem de Serviço', 'Saída OS', 'Saída Venda'),
         v.data_hora, CONCAT('Baixa automática - venda/OS #', v.id_venda)
    FROM venda v WHERE v.id_venda = NEW.id_venda;
  CALL sp_recalcular_venda(NEW.id_venda);
END$$

-- RN02/RN05: itens e históricos são imutáveis
CREATE TRIGGER trg_item_venda_bu BEFORE UPDATE ON item_venda
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN02: itens de venda são imutáveis; cancele a venda';
END$$

CREATE TRIGGER trg_item_venda_bd BEFORE DELETE ON item_venda
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN02: itens de venda não podem ser excluídos; cancele a venda';
END$$

-- RF08: toda movimentação atualiza o saldo (CHECK impede saldo negativo)
CREATE TRIGGER trg_mov_ai AFTER INSERT ON movimentacao_estoque
FOR EACH ROW
BEGIN
  IF NEW.tipo_movimentacao IN ('Entrada', 'Ajuste Positivo', 'Estorno Cancelamento') THEN
    UPDATE produto SET quantidade_estoque = quantidade_estoque + NEW.quantidade_mov
     WHERE id_produto = NEW.id_produto;
  ELSE
    UPDATE produto SET quantidade_estoque = quantidade_estoque - NEW.quantidade_mov
     WHERE id_produto = NEW.id_produto;
  END IF;
END$$

CREATE TRIGGER trg_mov_bu BEFORE UPDATE ON movimentacao_estoque
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN05: movimentações são imutáveis';
END$$

CREATE TRIGGER trg_mov_bd BEFORE DELETE ON movimentacao_estoque
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN05: movimentações não podem ser excluídas';
END$$

-- RF07, RN05 e RN06: histórico de preços com funcionário responsável
-- Antes de alterar preços execute: SET @id_funcionario_logado = <id do funcionário>;
CREATE TRIGGER trg_produto_bu BEFORE UPDATE ON produto
FOR EACH ROW
BEGIN
  IF NEW.preco_custo <> OLD.preco_custo OR NEW.preco_venda <> OLD.preco_venda THEN
    IF @id_funcionario_logado IS NULL THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RN06: defina @id_funcionario_logado antes de alterar preços';
    END IF;
    INSERT INTO historico_preco
      (id_produto, id_funcionario, preco_custo_antigo, preco_venda_antigo,
       preco_custo_novo, preco_venda_novo)
    VALUES
      (OLD.id_produto, @id_funcionario_logado, OLD.preco_custo, OLD.preco_venda,
       NEW.preco_custo, NEW.preco_venda);
  END IF;
END$$

CREATE TRIGGER trg_hist_bu BEFORE UPDATE ON historico_preco
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN05: histórico de preços é imutável';
END$$

CREATE TRIGGER trg_hist_bd BEFORE DELETE ON historico_preco
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN05: histórico de preços não pode ser excluído';
END$$

-- Ordem de serviço: precisa ser do tipo OS e ter cliente identificado
CREATE TRIGGER trg_os_bi BEFORE INSERT ON ordem_servico
FOR EACH ROW
BEGIN
  DECLARE v_tipo VARCHAR(20);
  DECLARE v_cliente INT UNSIGNED;
  SELECT tipo, id_cliente INTO v_tipo, v_cliente FROM venda WHERE id_venda = NEW.id_venda;
  IF v_tipo <> 'Ordem de Serviço' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A venda vinculada deve ser do tipo Ordem de Serviço';
  END IF;
  IF v_cliente IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN07: ordem de serviço exige cliente identificado';
  END IF;
END$$

CREATE TRIGGER trg_os_ai AFTER INSERT ON ordem_servico
FOR EACH ROW
BEGIN
  CALL sp_recalcular_venda(NEW.id_venda);
END$$

CREATE TRIGGER trg_os_au AFTER UPDATE ON ordem_servico
FOR EACH ROW
BEGIN
  CALL sp_recalcular_venda(NEW.id_venda);
END$$

-- RN09: venda cancelada não reabre e nunca é excluída; cancelamento estorna estoque
CREATE TRIGGER trg_venda_bu BEFORE UPDATE ON venda
FOR EACH ROW
BEGIN
  IF OLD.status = 'Cancelada' AND NEW.status <> 'Cancelada' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN09: venda cancelada não pode ser reaberta';
  END IF;
END$$

CREATE TRIGGER trg_venda_au AFTER UPDATE ON venda
FOR EACH ROW
BEGIN
  IF OLD.status <> 'Cancelada' AND NEW.status = 'Cancelada' THEN
    INSERT INTO movimentacao_estoque
      (id_produto, id_funcionario, id_venda, quantidade_mov, tipo_movimentacao, observacao)
    SELECT i.id_produto, NEW.id_funcionario, NEW.id_venda, i.quantidade,
           'Estorno Cancelamento', CONCAT('Estorno do cancelamento da venda/OS #', NEW.id_venda)
      FROM item_venda i WHERE i.id_venda = NEW.id_venda;
  END IF;
END$$

CREATE TRIGGER trg_venda_bd BEFORE DELETE ON venda
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN09: vendas não são excluídas; use status Cancelada';
END$$

DELIMITER ;
