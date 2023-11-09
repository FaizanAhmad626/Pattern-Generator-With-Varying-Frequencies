----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Faizan Ahmad
-- 
-- Create Date:
-- Design Name: Pattern Generator
-- Module Name: Clock_Divider - Behavioral
-- Project Name: Pattern_Generator_With_Varying_Frequencies
-- Target Devices: Basys 3 Artix-7 FPGA Trainer Board
-- Tool Versions: Vivado 2023.1
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Beginning of the Entity
entity Clock_Divider is
    port (
        Clock_100MHz    : in  std_logic;    -- Input Clock Signal with 100MHz Frequency
        Reset           : in  std_logic;    -- Reset Signal to reset sequential signals to their initial value
        Clock_Select    : in  std_logic;    -- If '0' then output clock will be 1Hz, if '1' then it will be 250Hz
        Divided_Clock   : out std_logic     -- Output Clock Signal containing either 1Hz or 250Hz Clock depending on user's input
    );
end entity Clock_Divider;

architecture Behavioral of Clock_Divider is

-- Required Constants and Signals
    constant Constant_for_250Hz : integer := 100000;    -- Counter max limit to achieve 250Hz Clock (Halved due to instantiation)
    constant Constant_for_1Hz   : integer := 25000000;  -- Counter max limit to achieve 1Hz Clock (Halved due to instantiation)
    
    signal Counter_1Hz   : unsigned(25 downto 0);   -- Counter for 1Hz Clock
    signal Counter_250Hz : unsigned(17 downto 0);   -- Counter  for 250Hz Clock
    signal Clock_1Hz     : std_logic;               -- Clock signal for 1Hz Clock
    signal Clock_250Hz   : std_logic;               -- Clock signal for 250Hz Clock
    
-- Beginning of the Performed Logic
begin
    -------------------------------------------------------------------
    -- This Process Block implements the counter for both clock signals
    -------------------------------------------------------------------
    process (Clock_100MHz, Reset)   -- Sensitivity List
    begin
        if Reset = '1' then         -- If Reset is high then initialize the counters from 0
            Counter_1Hz <= (others => '0');
            Counter_250Hz <= (others => '0');
            
        elsif rising_edge(Clock_100MHz) then    -- If Reset is low and rising edge of input clock
            if Counter_1Hz = Constant_for_1Hz - 1 then  
                Counter_1Hz <= (others => '0');         -- If Counter for 1Hz has reached it max required value then restart the counter from 0
            else                                        
                Counter_1Hz <= Counter_1Hz + 1;         -- otherwise increment the counter by 1
            end if;
            
            if Counter_250Hz = Constant_for_250Hz - 1 then
                Counter_250Hz <= (others => '0');       -- If Counter for 250Hz has reached it max required value then restart the counter from 0
            else
                Counter_250Hz <= Counter_250Hz + 1;     -- otherwise increment the counter by 1
            end if;
        end if;
    end process;
    
    -------------------------------------------
    -- This Process Block generates 250Hz Clock
    -------------------------------------------
    process (Clock_100MHz, Reset)   -- Sensitivity list
    begin
        if Reset = '1' then         -- If Reset is high then gives the clock 0 value
            Clock_250Hz <= '0';
            
        elsif rising_edge(Clock_100MHz) then    -- If Reset is low and rising edge of input clock
            if Counter_250Hz = Constant_for_250Hz - 1 then
                Clock_250Hz <= not Clock_250Hz; -- If Counter for 250Hz has reached it max required value then invert the clock
            else
                Clock_250Hz <= Clock_250Hz;     -- otherwise let it be the same as previous value
            end if;
        end if;
    end process;
    
    -----------------------------------------
    -- This Process Block generates 1Hz Clock
    -----------------------------------------
    process (Clock_100MHz, Reset)   -- Sensitivity list
    begin
        if Reset = '1' then         -- If Reset is high then gives the clock 0 value
            Clock_1Hz <= '0';
            
        elsif rising_edge(Clock_100MHz) then    -- If Reset is low and rising edge of input clock
            if Counter_1Hz = Constant_for_1Hz - 1 then
                Clock_1Hz <= not Clock_1Hz;     -- If Counter for 1Hz has reached it max required value then invert the clock
            else
                Clock_1Hz <= Clock_1Hz;         -- otherwise let it be the same as previous value
            end if;
        end if;
    end process;
    
    
    -- Assigning outputs
    Divided_Clock   <= Clock_1Hz    when Clock_Select = '0' else Clock_250Hz;   -- If Clock_Select is 0 then Clock_1Hz will go to output otherwise Clock250Hz
    
end architecture Behavioral;