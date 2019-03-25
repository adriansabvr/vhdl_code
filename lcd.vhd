----------------------------------------------------------------------------------
-- Escuela:             Instituto Politecnico Nacional ~ Escuela Superior de Computo
-- Maestro:             Erick linares
-- Integrantes:         adrian Sabanero Ramos ~ Diego alexis Trujillo Carcamo ~ Jorge
-- 
-- Fecha de creación:   14/03/2019 01:29 am
-- Nombre del módulo:   LCD Controller
-- Descripción: 
-- Controlador lcd en vhdl, para LCD 16*2. En especifico desarrollado para una altera
-- DE2, se necesita un clk de 50 MHz disponible en la altera y un divisor de frecuencia
-- a 400Hz este solo para manejar la maquina de estados. Se añade un diccionario en 
-- forma de lista, de los caracteres en hexadecimal que se desean imprimir y asi formar
-- la linea o string deseado.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions




ENTITY lcd_controller IS
   
   PORT( 
      clk           : IN     std_logic;  -- clk a 200Hz
      lcd_rs             : OUT    std_logic;
      lcd_e              : OUT    std_logic;
      lcd_rw             : OUT    std_logic;
      lcd_on             : OUT    std_logic;
      lcd_blon           : OUT    std_logic;
      selection			 : IN	std_logic_vector(3 downto 0);
      databus         : INOUT  std_logic_vector(7 downto 0)
   );

-- Declarations

END lcd_controller ;

--
ARCHITECTURE lcd_controller_arch OF lcd_controller IS
  type character_string is array ( 0 to 31 ) of STD_LOGIC_VECTOR( 7 downto 0 ); --- Matriz 32*8. Como el LCD es de 16*2 = 32 caracteres pero cada unos de esos caracteres esta representado por 8 bits
  
  type state_type is (func_set, display_on, mode_set, print_string,
                      line2, return_home, drop_lcd_e, reset1, reset2,
                       reset3, display_off, display_clear );
                       
  signal state, next_command         : state_type;
  
  
  signal lcd_display_string          : character_string;
  
  signal lcd_display_string_01       : character_string;
  
  signal data_bus_value, next_char   : STD_LOGIC_VECTOR(7 downto 0);
  signal clk_count_400hz             : STD_LOGIC_VECTOR(23 downto 0);
  signal char_count                  : STD_LOGIC_VECTOR(4 downto 0);
  signal clk_400hz_enable,lcd_rw_int : std_logic;

  signal data_bus                    : STD_LOGIC_VECTOR(7 downto 0);

BEGIN
  


--===================================================--  
-- SIGNAL STD_LOGIC_VECTORS assigned to OUTPUT PORTS
--===================================================--

databus <= data_bus;

    
--=====================================--


  

--===============================-- 
--  HD44780 CHAR DATA HEX VALUES --
--===============================-- 
--   = x"20",
-- ! = x"21",
-- " = x"22",
-- # = x"23",
-- $ = x"24",
-- % = x"25",
-- & = x"26",
-- ' = x"27",
-- ( = x"28",
-- ) = x"29",
-- * = x"2A",
-- + = x"2B",
-- , = x"2C",
-- - = x"2D",
-- . = x"2E",
-- / = x"2F",



-- 0 = x"30",
-- 1 = x"31",
-- 2 = x"32",
-- 3 = x"33",
-- 4 = x"34",
-- 5 = x"35",
-- 6 = x"36",
-- 7 = x"37",
-- 8 = x"38",
-- 9 = x"39",
-- : = x"3A",
-- ; = x"3B",
-- < = x"3C",
-- = = x"3D",
-- > = x"3E",
-- ? = x"3F",




-- Q = x"40",
-- A = x"41",
-- B = x"42",
-- C = x"43",
-- D = x"44",
-- E = x"45",
-- F = x"46",
-- G = x"47",
-- H = x"48",
-- I = x"49",
-- J = x"4A",
-- K = x"4B",
-- L = x"4C",
-- M = x"4D",
-- N = x"4E",
-- O = x"4F",



-- P = x"50",
-- Q = x"51",
-- R = x"52",
-- S = x"53",
-- T = x"54",
-- U = x"55",
-- V = x"56",
-- W = x"57",
-- X = x"58",
-- Y = x"59",
-- Z = x"5A",
-- [ = x"5B",
-- Y! = x"5C",
-- ] = x"5D",
-- ^ = x"5E",
-- _ = x"5F",



-- \ = x"60",
-- a = x"61",
-- b = x"62",
-- c = x"63",
-- d = x"64",
-- e = x"65",
-- f = x"66",
-- g = x"67",
-- h = x"68",
-- i = x"69",
-- j = x"6A",
-- k = x"6B",
-- l = x"6C",
-- m = x"6D",
-- n = x"6E",
-- o = x"6F",



-- p = x"70",
-- q = x"71",
-- r = x"72",
-- s = x"73",
-- t = x"74",
-- u = x"75",
-- v = x"76",
-- w = x"77",
-- x = x"78",
-- y = x"79",
-- z = x"7A",
-- { = x"7B",
-- | = x"7C",
-- } = x"7D",
-- -> = x"7E",
-- <- = x"7F",


 lcd_display_string_01 <= 
  (
-- Line 1    o    p     e     r      a     t     i     o    n     :                         
          x"6F",x"70",x"65",x"72",x"61",x"74",x"69",x"6F",x"6E",x"3A",x"20",x"20",x"20",x"20",x"20",x"20",
   
-- Line 2    a     d     d    r      e    s     s      :
          x"61",x"64",x"64",x"72",x"65",x"73",x"73",x"3A",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20" 
   );
   

-- Se necesitan hacer todas las operaciones:
-- Linea 1 para operacion
-- Linea 2 para direccion

 
   
   



-------------------------------------------------------------------------------------------------------
-- BIDIRECTIONAL TRI STATE LCD DATA BUS
   data_bus <= data_bus_value when lcd_rw_int = '0' else "ZZZZZZZZ";
   
-- LCD_RW PORT is assigned to it matching SIGNAL 
 lcd_rw <= lcd_rw_int;
 
next_char <= lcd_display_string_01(CONV_INTEGER(char_count));
 
 
 PROCESS (selection)
BEGIN
  

     CASE (selection) IS
          
          -- SUMA
       WHEN "0000" =>
            next_char <= lcd_display_string_01(CONV_INTEGER(char_count));
                                                                                                                
                 --  BLUETOOTH CONTROLLER                                                                 
            WHEN OTHERS =>              
               next_char <= lcd_display_string_01(CONV_INTEGER(char_count));
                                                     
       END CASE;
END PROCESS;
  
--======================== LCD DRIVER CORE ==============================--   
--                     STATE MACHINE WITH RESET                          --  Utiliza el clk a 400hz para la maquina de estados.
--===================================================-----===============--  
process (clk)
begin
        if(clk'event and clk='1') then 
                 
                 
                 
              --========================================================--                 
              -- State Machine to send commands and data to LCD DISPLAY
              --========================================================--
                 case state is
                       
                       
                       
--======================= INITIALIZATION START ============================--
                       when reset1 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_lcd_e;
                            next_command <= reset2;
                            char_count <= "00000";
  
                       when reset2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_lcd_e;
                            next_command <= reset3;
                            
                       when reset3 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_lcd_e;
                            next_command <= func_set;
            
            
                       -- Function Set
                       --==============--
                       when func_set =>                
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38";  -- Set Function to 8-bit transfer, 2 line display and a 5x8 Font size
                            state <= drop_lcd_e;
                            next_command <= display_off;
                            
                            
                            
                       -- Turn off Display
                       --==============-- 
                       when display_off =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"08"; -- Turns OFF the Display, Cursor OFF and Blinking Cursor Position OFF.......
                                                     -- (0F = Display ON and Cursor ON, Blinking cursor position ON)
                            state <= drop_lcd_e;
                            next_command <= display_clear;
                           
                           
                       -- Clear Display 
                       --==============--
                       when display_clear =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"01"; -- Clears the Display    
                            state <= drop_lcd_e;
                            next_command <= display_on;
                           
                           
                           
                       -- Turn on Display and Turn off cursor
                       --===================================--
                       when display_on =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"0C"; -- Turns on the Display (0E = Display ON, Cursor ON and Blinking cursor OFF) 
                            state <= drop_lcd_e;
                            next_command <= mode_set;
                          
                          
                       -- Set write mode to auto increment address and move cursor to the right
                       --====================================================================--
                       when mode_set =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"06"; -- Auto increment address and move cursor to the right
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                            
                                
--======================= INITIALIZATION END ============================--                          
                          
                          
                          
                          
--=======================================================================--                           
--               Write ASCII hex character Data to the LCD
--=======================================================================--
                       when print_string =>          
                            state <= drop_lcd_e;
                            lcd_e <= '1';
                            lcd_rs <= '1';
                            lcd_rw_int <= '0';
                          
                          
                               -- ASCII character to output
                               -----------------------------
                               -- Below we check to see if the Upper-Byte of the HEX number being displayed is x"0"....We use this number x"0" as a Control Variable, 
                               -- to know when a certain condition is met.  Next, we proceed to process the "next_char" variable to Sequentially count up in HEX format.
                               
                               -- This is required because as you know...Counting in HEX...after #9 comes Letter A.... well if you look at the ASCII CHART, 
                               -- the Letters A,B,C etc. are in a different COLUMN compared to the one the Decimal Numbers are in.  Letters A...F are in Column  x"4".    
                               -- Numbers 0...9 are in Column x"3".  The Upper-Byte controls which COLUMN the Character will be selected from... and then Displayed on the LCD. 
                               
                               -- So to Count up seamlessly using our 4-Bit Variable 8,9,10,11 and so on...we need to set some IF THEN ELSE conditions 
                               -- to control this changing of Columns so that it will be displayed counting up in HEX Format....8,9,A,B,C,D etc.
                                
                               -- Also, if the High-Byte is detected as an actual Character Column from the ASCII CHART that has Valid Characters 
                               -- (Like using a Upper-Byte of x"2",x"3",x"4",x"5",x"6" or x"7") then it will just go ahead and decalre  "data_bus_value <= next_char;"  
                               -- and the "Print_Sring" sequence will continue to execute. These HEX Counting conditions are only being applied to the Variables that have 
                               -- the x"0" Upper-Byte value.....For our code that is the:  [x"0"&hex_display_data]  variable.  
                               
                               
                               if (next_char(7 downto 4) /= x"0") then
                                  data_bus_value <= next_char;
                               else
                             
                                    -- Below we process a 4-bit STD_LOGIC_VECTOR that is counting up Sequentially, we process the values so that it Displays in HEX Format as it counts up.
                                    -- In our case, our SWITCHES have been Mapped to a 4-bit STD_LOGIC_VECTOR and we have placed an Upper-Byte value of x"0" before it.
                                    -- This triggers the Process below, which will condition which numbers and letters are displayed on the LCD as the 4-Bit Variable counts up past #9 or 1001
                                    -------------------------------------------------------------------------------------------------------------------------------------------------------------
                                    
                                    -- if the number is Greater than 9..... meaning the number is now in the Realm of HEX... A,B,C,D,E,F... then
                                    if next_char(3 downto 0) >9 then 
                              
                                    -- See the ASCII CHART... Letters A...F are in Column  x"4"
                                      data_bus_value <= x"4" & (next_char(3 downto 0)-9);  
                                    else 
                                
                                    -- See the ASCII CHART... Numbers 0...9 are in Column x"3"
                                      data_bus_value <= x"3" & next_char(3 downto 0);
                                    end if;
                               end if;
                          
                          
                          

                            -- Loop to send out 32 characters to LCD Display (16 by 2 lines)
                               if (char_count < 31) AND (next_char /= x"fe") then
                                   char_count <= char_count +1;                            
                               else
                                   char_count <= "00000";
                               end if;
                  
                  
                  
                            -- Jump to second line?
                               if char_count = 15 then 
                                  next_command <= line2;
                   
                   
                   
                            -- Return to first line?
                               elsif (char_count = 31) or (next_char = x"fe") then
                                     next_command <= return_home;
                               else 
                                     next_command <= print_string; 
                               end if; 
                 
                 
                 
                       -- Set write address to line 2 character 1
                       --======================================--
                       when line2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"c0";
                            state <= drop_lcd_e;
                            next_command <= print_string;      
                     
                     
                       -- Return write address to first character position on line 1
                       --=========================================================--
                       when return_home =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"80";
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                    
                    
                    
                       -- The next states occur at the end of each command or data transfer to the LCD
                       -- Drop LCD E line - falling edge loads inst/data to LCD controller
                       --============================================================================--
                       when drop_lcd_e =>
                            state <= next_command;
                            lcd_e <= '0';
                            lcd_blon <= '1';
                            lcd_on   <= '1';
                        end case;
             
      end if;
      
end process;                                                            
  
END ARCHITECTURE lcd_controller_arch;



            