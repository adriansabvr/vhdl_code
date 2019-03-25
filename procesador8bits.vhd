----------------------------------------------------------------------------------
-- Escuela:             Instituto Politecnico Nacional ~ Escuela Superior de Computo
-- Maestro:             Erick linares
-- Integrantes:         adrian Sabanero Ramos ~ Diego alexis Trujillo Carcamo ~ Jorge
-- 
-- Fecha de creación:   02/03/2019 01:30 pm
-- Nombre del módulo:   Procesador 8 bits
-- Descripción: 
-- Modulo superior de un procesador de 8 bits, que cuenta con una ALU, RAM, BCD7SEGMENTOS.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity procesador8bits is
	port (
		-- CLOCK
		clk : in std_logic;
		
		-- ALU
		v : in std_logic_vector(7 downto 0);
		to_a: in std_logic;
		to_b: in std_logic;
		selection : in std_logic_vector(3 downto 0);
		
		-- RAM
		wr: in std_logic;
		rd: in std_logic;
		addr : in std_logic_vector(2 downto 0);
		
		
		
		
		-- 7 SEGMENTS
		digito_salida1 : out std_logic_vector(6 downto 0);
		digito_salida2 : out std_logic_vector(6 downto 0);
		digito_salida3 : out std_logic_vector(6 downto 0)
	);
end procesador8bits;

architecture procesador8bits_arc of procesador8bits is


component siete_segmentos
	port (
		entrada : in std_logic_vector(3 downto 0);  -- El siete segmentos a lo mas puede representar un 9 el cual solo ocupa 4 bits. Se podrian ocupar mas bits para representar letras y signos.
		salida : out std_logic_vector(6 downto 0)	-- El siete segmentos tiene 8 entradas. 7 que conforman al numero y 1 para el decimal.
	);
end component;


component bin2bcd is
	generic (
			n : integer := 9;	-- Numero de bits que corresponden al valor de entrada. 
			m : integer := 11	-- Numero de bits que se necesitan para representar los numeros. Ejemplo: 2^5=32 se verifica el primer numero 3->2bits por cada digito despues del primero se suma 4 es decir 6 bits 
		);
	port (
		entrada : in std_logic_vector(n-1 downto 0);
		salida :  out std_logic_vector(m-1 downto 0)
	);
end component;

component alu is
  generic (
      n : integer := 8;  -- Numero de bits para los vectores de entrada
      m : natural := 1  -- Numero de rotaciones/corrimientos en la alu
    );
  port (
	clk: in std_logic;
    v : in std_logic_vector(n-1 downto 0);
    to_a: in std_logic;
	to_b: in std_logic;
	wr: in std_logic;
	rd: in std_logic;
    permision : in std_logic;
    addr : in std_logic_vector(2 downto 0);
    selection : in std_logic_vector(3 downto 0);              -- El tamaño del selection depende del numero de instrucciones que se deseen. 2^5 = 32 me alcanza para poner 32 instrucciones
    salida : inout std_logic_vector(n-1 downto 0);             --Para la salida depende del valor maximo que pueda dar, como en esta alu la operacion que crea un numero mas grande es la suma por los 4 bits 16 + 16 = 32 se necesitan 5 bits
    carry_out : out std_logic
  );
end component;

component clk200hz is
    Port (
        clk: in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        clk_out : out STD_LOGIC
    );
end component;

component lcd_controller IS
   
   port( 
      clk           : IN     std_logic;  -- clk a 200Hz
      lcd_rs             : OUT    std_logic;
      lcd_e              : OUT    std_logic;
      lcd_rw             : OUT    std_logic;
      lcd_on             : OUT    std_logic;
      lcd_blon           : OUT    std_logic;
      selection			 : IN	std_logic_vector(3 downto 0);
      databus         : INOUT  std_logic_vector(7 downto 0)
   );


end component ;

signal carry_out : std_logic := '0';
signal num_bcd : std_logic_vector(10 downto 0);
signal resultado : std_logic_vector(7 downto 0);
signal D0, D1, D2: std_logic_vector(3 downto 0);
signal extra : std_logic_vector(8 downto 0);
signal permision : std_logic := '1';
signal clk_out : std_logic := '0';
signal reset : std_logic := '0';

begin

	
	alu_i: alu PORT MAP(
			clk, v, to_a, to_b, wr, rd, permision, addr, selection, resultado, carry_out
		);
	
	extra <= carry_out & resultado;
	bcd_i: bin2bcd PORT MAP(
			extra, num_bcd
		);
	
	D2 <= '0' & num_bcd(10 downto 8);
	D1 <= num_bcd(7 downto 4);
	D0 <= num_bcd(3 downto 0); 


	seg_1: siete_segmentos PORT MAP(
	        D0, digito_salida1
	    );
		
	seg_2: siete_segmentos PORT MAP( 
	        D1, digito_salida2
	    );
		
	seg_3: siete_segmentos PORT MAP( 
	        D2, digito_salida3
	    );
end procesador8bits_arc;