----------------------------------------------------------------------------------
-- Escuela:             Instituto Politecnico Nacional ~ Escuela Superior de Computo
-- Maestro:				Erick linares
-- Integrantes:         Adrian Sabanero Ramos ~ Diego Alexis Trujillo Carcamo ~ Jorge
-- 
-- Fecha de creación:   02/03/2019 01:35 am
-- Nombre del módulo:   siete_segmentos
-- Descripción: 
--   Decodificador de 4 bits a siete segmentos. Se incluyen los números del 0
--   al 9.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity siete_segmentos is
	port (
		entrada : in std_logic_vector(3 downto 0);  -- El siete segmentos a lo mas puede representar un 9 el cual solo ocupa 4 bits. Se podrian ocupar mas bits para representar letras y signos.
		salida : out std_logic_vector(6 downto 0)	-- El siete segmentos tiene 8 entradas. 7 que conforman al numero y 1 para el decimal.
	);
end siete_segmentos;

architecture siete_segmentos_arc of siete_segmentos is
begin

	visualizador : process(entrada)
	begin
		case entrada is
			when "0000" => salida <= "1000000"; -- 0
            when "0001" => salida <= "1111100"; -- 1
            when "0010" => salida <= "0100100"; -- 2
            when "0011" => salida <= "0110000"; -- 3
            when "0100" => salida <= "0011001"; -- 4
            when "0101" => salida <= "0010010"; -- 5
            when "0110" => salida <= "0000011"; -- 6
            when "0111" => salida <= "0111000"; -- 7
            when "1000" => salida <= "0000000"; -- 8
            when "1001" => salida <= "0011000"; -- 9
			when others => salida <= "1111110";
        end case;
	end process;

end siete_segmentos_arc;