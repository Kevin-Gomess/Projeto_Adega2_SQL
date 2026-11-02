
  IF v_total IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Fiado nao encontrado.';
  END IF;

  IF NEW.vl_pago <= 0 OR v_pago + NEW.vl_pago > v_total THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Pagamento invalido: valor deve ser positivo e nao pode ultrapassar a divida.';
  END IF;
END$$

-- Soma o recebimento ao fiado e atualiza ABERTO/QUITADO.
CREATE TRIGGER trg_pagamento_fiado_atualiza
AFTER INSERT ON pagamento_fiado
FOR EACH ROW
BEGIN
  UPDATE fiado
     SET vl_pago = vl_pago + NEW.vl_pago
   WHERE id_fiado = NEW.id_fiado;
END$$

-- Registra uma venda integralmente no fiado em uma unica transacao.
-- A venda e seus itens devem existir antes da chamada. A procedure cria:
-- 1) a conta de fiado; 2) os vinculos de todos os itens da venda;
-- 3) o registro de pagamento na forma FIADO.
-- Se qualquer etapa falhar, tudo e desfeito (ROLLBACK).
CREATE PROCEDURE sp_registrar_venda_fiado_completo(
  IN p_id_venda BIGINT UNSIGNED,
  IN p_id_cliente INT UNSIGNED,
  IN p_dt_vencimento DATE
)
BEGIN
  DECLARE v_total DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_bloqueado TINYINT DEFAULT NULL;
  DECLARE v_qt_itens INT DEFAULT 0;
  DECLARE v_ja_tem_fiado INT DEFAULT 0;
  DECLARE v_ja_tem_pagamento INT DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  SELECT vl_total
    INTO v_total
    FROM venda
   WHERE id_venda = p_id_venda
     AND st_venda = 'CONCLUIDA'
   FOR UPDATE;

  IF v_total IS NULL OR v_total <= 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Venda nao encontrada, cancelada ou com total invalido.';
  END IF;

  SELECT fl_bloqueado
    INTO v_bloqueado
    FROM cliente
   WHERE id_cliente = p_id_cliente
   FOR UPDATE;

  IF v_bloqueado IS NULL OR v_bloqueado = 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cliente nao encontrado ou bloqueado para compras fiado.';
  END IF;

  SELECT COUNT(*)
    INTO v_qt_itens
    FROM item_venda
   WHERE id_venda = p_id_venda;

  IF v_qt_itens = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A venda precisa possuir ao menos um item antes de virar fiado.';
  END IF;

  SELECT COUNT(*)
    INTO v_ja_tem_fiado
    FROM fiado
   WHERE id_venda = p_id_venda;

  SELECT COUNT(*)
    INTO v_ja_tem_pagamento
    FROM pagamento
   WHERE id_venda = p_id_venda;

  IF v_ja_tem_fiado > 0 OR v_ja_tem_pagamento > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A venda ja possui fiado ou pagamento; nao e possivel registra-la novamente por esta procedure.';
  END IF;

  INSERT INTO fiado
    (id_venda, id_cliente, dt_vencimento, vl_total, vl_pago)
  VALUES
    (p_id_venda, p_id_cliente, p_dt_vencimento, v_total, 0.00);

  INSERT INTO item_fiado (id_item_venda)
  SELECT id_item_venda
    FROM item_venda
   WHERE id_venda = p_id_venda;

  INSERT INTO pagamento (id_venda, tp_forma, vl_pago)
  VALUES (p_id_venda, 'FIADO', v_total);

  COMMIT;
END$$

DELIMITER ;
