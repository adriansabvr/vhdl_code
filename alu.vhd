----------------------------------------------------------------------------------
-- Escuela:             Instituto Politecnico Nacional ~ Escuela Superior de Computo
-- Maestro:             Erick linares
-- Integrantes:         adrian Sabanero Ramos ~ Diego alexis Trujillo Carcamo ~ Jorge
-- 
-- Fecha de creación:   02/03/2019 02:13 am
-- Nombre del módulo:   alu
-- Descripción: 
--   Diseño de una alu de 8 bits con ram integrada para guardar o leer resultados.
--   
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity alu is
  generic (
      n : integer := 8;  -- Numero de bits para los vectores de entrada
      m : natural := 1  -- Numero de rotaciones/corrimientos en la alu
    );
  port (
  clk : in std_logic;
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
end alu;

architecture alu_arc of alu is
  signal tmp: std_logic_vector (n downto 0);
  signal result: std_logic_vector (n-1 downto 0);
  
  component ram
  port(
     addr : in std_logic_vector(19 downto 0); -- Direccion de la ram
     data_in : in std_logic_vector(15 downto 0); -- Datos a escribir
     enable : in std_logic;
     wr: in std_logic; -- Leer
     rd: in std_logic; -- Escribir
     data_out : out std_logic_vector(15 downto 0) -- Salida de datos
  );
  end component;
  
  
type control_unit is (off, init, instruction, getA, getB, rd1, rd2, wr1, stand_by, wr2, wr3, fetch);  -- Estados definidos
signal state : control_unit;
signal a, b : std_logic_vector(7 downto 0);
  
-- Señales para la ram. En caso de que ya se utilice la SRAM solo hay que hacer las conexiones desde el entity.
signal addr2 : std_logic_vector(19 downto 0) := "00000000000000000000";
signal data_in : std_logic_vector(15 downto 0) := "0000000000000000"; -- Datos a escribir
signal enable : std_logic;
signal data_out : std_logic_vector(15 downto 0); -- Salida de datos
signal bb : std_logic := '1';
    

begin

  ram_i : ram PORT MAP(
      addr2, data_in, enable, wr, rd, data_out
    );

  proceso_alu : process(v, selection, to_a, to_b, wr, rd, addr, permision, clk)
  begin
	if(clk'event and clk='1') then
	
	if(permision ='0') then
	state <= off;
	end if;
	
	if (to_a = '0' ) then
          state <= getA;
        elsif (to_b = '0') then
          state <= getB;
        end if;

        if (rd = '0' and state /= rd2 and state /= stand_by) then
          state <= rd1;
        elsif (wr = '0' and state /= wr2) then
          state <= wr1;
        end if;

    case(state) is

      when off =>
	  if(permision = '1') then
      state <= init;
		end if;
		
      when init => 
        a <= "00000000";
        b <= "00000000";
        state <= fetch;

      when getA =>
        a <= v;
        state <= fetch;

      when getB =>
        b <= v;
        state <= fetch;

      when rd1 =>
        enable <= '1';
        addr2 <= "00000000000000000" & addr;
		state <= rd2;
	
	when rd2 =>
		salida <= data_out(7 downto 0);
        carry_out <= data_out(8);
        state <= stand_by;

      when stand_by =>
        if (rd = '1') then
          state <= fetch;
		else 
			state <= stand_by;
        end if;

      when wr1 =>
        enable <= '1';
        data_in <= "0000000" & (tmp(8) & salida);
		addr2 <= "00000000000000000" & addr;
        state <= wr2;

      when wr2 =>
		enable <= '0';
        state <= wr3;
	
	 when wr3 =>
		state <= fetch;
		
	  when fetch =>
		enable <= '0';
		state <= instruction;

      when instruction =>
	  
	  if (selection = "0000") then
                tmp <= ('0' & a) + ('0' & b);
                else
                tmp <= "000000000";
                end if;
	   carry_out <= tmp(8);

        case(selection) is
              -- Aritmeticas
              when "0000" => 

            salida <= a + b ; -- Suma
            
              when "0001" => salida <= a - b ; -- Resta

              -- 
              when "0010" => salida <= std_logic_vector(unsigned(a) sll m); -- Shift left
              when "0011" => salida <= std_logic_vector(unsigned(a) srl m); -- Shift Right  
              when "0100" => salida <= std_logic_vector(unsigned(a) rol m); -- Rotate left
              when "0101" => salida <= std_logic_vector(unsigned(a) ror m); -- Rotate right

              -- Logicas
              when "0110" => salida <= a and b;
              when "0111" => salida <= a or b;
              when "1000" => salida <= a xor b;
              when "1001" => salida <= a nor b;
              when "1010" => salida <= a nand b;
              when "1011" => salida <= a xnor b;

              when others => salida <= a + b ;   -- Otros? 

        end case;

        
          
          

    end case;
	end if;
 
  end process;

end alu_arc;