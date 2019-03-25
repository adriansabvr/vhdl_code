----------------------------------------------------------------------------------
-- Escuela:             Instituto Politecnico Nacional ~ Escuela Superior de Computo
-- Maestro:				Erick linares
-- Integrantes:         Adrian Sabanero Ramos ~ Diego Alexis Trujillo Carcamo ~ Jorge
-- 
-- Fecha de creación:   02/03/2019 01:46 am
-- Nombre del módulo:   bin2bcd
-- Descripción: 
--   Convertidor de binario n a bcd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity bin2bcd is
	generic (
			n : integer := 9;	-- Numero de bits que corresponden al valor de entrada. 
			m : integer := 11	-- Numero de bits que se necesitan para representar los numeros. Ejemplo: 2^5=32 se verifica el primer numero 3->2bits por cada digito despues del primero se suma 4 es decir 6 bits 
		);
	port (
		entrada : in std_logic_vector(n-1 downto 0);
		salida :  out std_logic_vector(m-1 downto 0)
	);
end bin2bcd;

architecture bin2bcd_arc of bin2bcd is
begin
    proceso_bcd: process(entrada)
        variable z: std_logic_vector(n+m-1 downto 0);
    begin
        -- Inicialización de datos en cero.
        z := (others => '0');
        -- Se realizan los primeros tres corrimientos.
        z(n+2 downto 3) := entrada;
        -- Ciclo para las iteraciones restantes.
        for i in 0 to n-4 loop
            -- Unidades (4 bits).
            if z(n+3 downto n) > 4 then
                z(n+3 downto n) := z(n+3 downto n) + 3;
            end if;
            -- Decenas (2 bits).
            if z(n+7 downto n+4) > 4 then
                z(n+7 downto n+4) := z(n+7 downto n+4) + 3;
            end if;
            -- Centenas (3 bits).
            if z(n+10 downto n+8) > 4 then
                z(n+10 downto n+8) := z(n+10 downto n+8) + 3;
            end if;
            -- Corrimiento a la izquierda.
            z(n+m-1 downto 1) := z(n+m-2 downto 0);
        end loop;
        -- Pasando datos de variable Z, correspondiente a BCD.
        salida <= z(n+m-1 downto n);
    end process;
end bin2bcd_arc;