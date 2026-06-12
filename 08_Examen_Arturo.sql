CREATE TABLE Auditoria_Clientes(
id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
id_cliente INT NOT NULL,
campo_modificado VARCHAR(100),
valor_antiguo VARCHAR (200),
valor_nuevo VARCHAR (200),
fecha_modificado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);




DROP TRIGGER IF EXISTS trg_audit_cliente_after_update;

CREATE TRIGGER trg_audit_cliente_after_update
AFTER UPDATE ON clientes
FOR EACH ROW
BEGIN
    IF OLD.email <> NEW.email THEN
        INSERT INTO Auditoria_Clientes(id_cliente, campo_modificado, valor_antiguo, valor_nuevo)
        VALUES (OLD.id, 'email', OLD.email, NEW.email);
    END IF;
   OR
   IF OLD.direccion_envio <> NEW.direccion_envio THEN
        INSERT INTO Auditoria_Clientes(id_cliente, campo_modificado, valor_antiguo, valor_nuevo)
        VALUES (OLD.id, 'direccion_envio', OLD.direccion_envio, NEW.direccion_envio);
    END IF;
END;


UPDATE clientes  SET email = 'contactos@techsupplier.com' WHERE id = 1;

UPDATE clientes  SET direccion_envio  = 'cra21b#115-116' WHERE id = 1;

SELECT * FROM Auditoria_Clientes;
