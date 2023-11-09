----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Faizan Ahmad
-- 
-- Create Date:
-- Design Name: Pattern Generator
-- Module Name: Top_Module - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Beginning of the Entity
entity Top_Module is
    port (
        Main_Clock   : in std_logic;    -- Main 100MHz Clock from Oscillator
        Reset        : in std_logic;    -- Reset Signal from FPGA Board
        Clock_Select : in std_logic;    -- Given by user: If '0' then output clock will be 1Hz, if '1' then it will be 250Hz
        Wave_Select  : in std_logic;    -- Given by user: If '0' then SQ1 and SQ2 will go to output otherwise TRW and SAW
        Go           : in std_logic;    -- Given by user: Go signal to initialize data generation
        Seg          : out std_logic_vector(6 downto 0);    -- Output to Cathodes of 7-segment from CG to CA
        AN           : out std_logic_vector(3 downto 0)     -- Output to Anodes of 7-segment from AN7 to AN0
    );
end entity Top_Module;

architecture Behavioral of Top_Module is

-- Required Signals
    signal Divided_Clock : std_logic;   -- Clock Signal containing either 1Hz or 250Hz Clock depending on user's input
    signal C0, C1        : std_logic_vector(7 downto 0);    -- Data signal containing SQ1 and TRW or SQ2 and SAW waveform 
    
-- Beginning of the Performed Logic    
begin

    ------------------------------
    -- Instantiating Clock Divider
    ------------------------------
    clock_divider : entity work.Clock_Divider
        port map (
            Clock_100MHz => Main_Clock,
            Reset => Reset,
            Clock_Select => Clock_Select,
            Divided_Clock => Divided_Clock
        );

    -------------------------------
    -- Instantiating Pattern Generator
    -------------------------------
    pattern_generator : entity work.Pattern_Generator
        port map (
            Reset => Reset,
            Go => Go,
            Wave_Select => Wave_Select,
            Divided_Clock => Divided_Clock,
            C0 => C0,
            C1 => C1
        );

    -------------------------------
    -- Instantiating Display Driver
    -------------------------------          
     display_driver : entity work.Display_Driver
        port map (
        Clock_100MHz => Main_Clock,
        Reset => Reset,
        C0 => C0,
        C1 => C1,
        Seg => Seg,
        AN => AN
        );       
        
end architecture Behavioral;