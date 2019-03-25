----------------------------------------------------------------------------------
-- Escuela:             Instituto Politecnico Nacional ~ Escuela Superior de Computo
-- Maestro:             Erick linares
-- Integrantes:         adrian Sabanero Ramos ~ Diego alexis Trujillo Carcamo ~ Jorge
-- 
-- Fecha de creación:   02/03/2019 01:13 pm
-- Nombre del módulo:   clk200hz Divisor de frecuencia
-- Descripción: 
-- Divisor de frecuencia que toma como entrada una señal de 50 MHz y se dese una 
-- salida de 200Hz, el contador para el divisor de frecuencia tiene como función 
-- generar la señal de salida de 200Hz cada 250000 ciclos. 125K en alto y en bajo.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions
 
entity clk200hz is
    Port (
        clk: in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        clk_out : out STD_LOGIC
    );
end clk200hz;
 
architecture clk200hz_arc of clk200hz is
    signal temporal: STD_LOGIC := '0';
    signal contador: integer := 1;
 
begin
 
	process(clk,reset)
	begin
		if(reset='1') then
			contador<=1;
			temporal<='0';
		elsif(clk'event and clk='1') then
			contador <=contador+1;
			if (contador = 124999) then
				temporal <= NOT temporal;
				contador <= 1;
			end if;
		end if;
		clk_out <= temporal;
	end process;
end clk200hz_arc;