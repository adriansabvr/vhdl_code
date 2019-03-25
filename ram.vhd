----------------------------------------------------------------------------------
-- Escuela:             Instituto Politecnico Nacional ~ Escuela Superior de Computo
-- Maestro:             Erick linares
-- Integrantes:         adrian Sabanero Ramos ~ Diego alexis Trujillo Carcamo Jorge Padilla 
-- 
-- Fecha de creación:   07/03/2019 07:53 pm
-- Nombre del módulo:   ram
-- Descripción: 
--   Modulo de emulacion SRAM de la altera DE2. Que servira para realizar la practica 2
--   Cabe resaltar que este archivo tiene que ser retirado y utilizar la SRAM interna.
--   Se añade un modulo SRAM controller para este proposito. 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions


entity ram is
port(
 addr : in std_logic_vector(19 downto 0); -- Direccion de la ram
 data_in : in std_logic_vector(15 downto 0); -- Datos a escribir
 enable : in std_logic;
 wr: in std_logic; -- Leer
 rd: in std_logic; -- Escribir
 data_out : out std_logic_vector(15 downto 0) -- Data output of RAM
);
end ram;

architecture ram_arc of ram is
-- define the new type for the pow(2,20)x16 RAM.... Como solo utilizaremos 3 bits de direcciones 8*16 
type RAM_ARRAY is array (0 to  7) of std_logic_vector (15 downto 0);
-- initial values in the RAM
signal RAM: RAM_ARRAY :=(
   "0000000000000000",
   "0000000000000000",
   "0000000000000000",
   "0000000000000000",
   "0000000000000000",
   "0000000000000000",
   "0000000000000000",
   "0000000000000000"
   ); 
begin
process(enable)
begin
 if(enable='1') then
    if(wr='1' and rd='0') then -- when write enable = 1, 
    -- write input data into RAM at the provided address
    RAM(to_integer(unsigned(addr))) <= data_in;
    -- The index of the RAM array type needs to be integer so
    -- converts RAM_ADDR from std_logic_vector -> Unsigned -> Interger using numeric_std library
    elsif (wr='0' and rd='1') then
    data_out <= RAM(to_integer(unsigned(addr)));
       
    end if;
 end if;
end process;
 
end ram_arc;