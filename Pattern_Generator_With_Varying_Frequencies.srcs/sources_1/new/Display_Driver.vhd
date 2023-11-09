----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Faizan Ahmad
-- 
-- Create Date:
-- Design Name: Pattern Generator
-- Module Name: Display_Driver - Behavioral
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
entity Display_Driver is
    port(
        Clock_100MHz : in std_logic;                     -- Input Clock Signal with 100MHz Frequency
        Reset        : in std_logic;                     -- Reset Signal to reset sequential signals to their initial value
        C0           : in std_logic_vector(7 downto 0);  -- First input data either contain SQ1 or TRW
        C1           : in std_logic_vector(7 downto 0);  -- Second input data either contain SQ2 or SAW
        Seg          : out std_logic_vector(6 downto 0); -- Output to Cathodes from CG to CA
        AN           : out std_logic_vector(3 downto 0)  -- Output to Anodes from AN7 to AN0
    );
end Display_Driver;

architecture Behavioral of Display_Driver is

-- Required States, Signals, and Constants
    type state_type is (AN0, AN1, AN2, AN3);    -- States for FSM for rotation of Anodes
    
    signal Digit        : state_type;   -- State register for FSM
    signal Segment      : std_logic_vector(6 downto 0);     -- To store the value of 7-segment LEDs
    signal Data         : std_logic_vector(15 downto 0);    -- To store the incoming data
    signal Counter_1kHz : unsigned(14 downto 0) := (others => '0');   -- Counter for 1kHz Clock
    signal Clock_1kHz   : std_logic             := '0';               -- Clock signal for 1kHz Clock
    
    constant Constant_for_1kHz : integer := 25000;    -- Counter max limit to achieve 1kHz Clock (Halved due to instantiation)

-- 2D Array containing Hexadecimal to 7-segment Display conversion table
    type NUM_array is array (0 to 15) of std_logic_vector(6 downto 0);
    constant NUM : NUM_array := (
        "1000000",  -- 0
        "1111001",  -- 1
        "0100100",  -- 2
        "0110000",  -- 3
        "0011001",  -- 4
        "0010010",  -- 5
        "0000010",  -- 6
        "1111000",  -- 7
        "0000000",  -- 8
        "0010000",  -- 9
        "0001000",  -- A
        "0000011",  -- B
        "1000110",  -- C
        "0100001",  -- D
        "0000110",  -- E
        "0001110"   -- F
    );

    
-- Beginning of the Performed Logic
begin
    ------------------------------------------------------------
    -- This Process Block implements the counter for 1 kHz Clock
    ------------------------------------------------------------
    process (Clock_100MHz, Reset)   -- Sensitivity List
    begin
        if Reset = '1' then         -- If Reset is high then initialize the counters from 0
            Counter_1kHz <= (others => '0');
            
        elsif rising_edge(Clock_100MHz) then        -- If Reset is low and rising edge of input clock
            if Counter_1kHz = Constant_for_1kHz - 1 then  
                Counter_1kHz <= (others => '0');    -- If Counter for 1Hz has reached it max required value then restart the counter from 0
            else                                        
                Counter_1kHz <= Counter_1kHz + 1;   -- otherwise increment the counter by 1
            end if;
          
        end if;
    end process;
    
    -------------------------------------------
    -- This Process Block generates 1 kHz Clock
    -------------------------------------------
    process (Clock_100MHz, Reset)   -- Sensitivity list
    begin
        if Reset = '1' then         -- If Reset is high then gives the clock 0 value
            Clock_1kHz <= '0';
            
        elsif rising_edge(Clock_100MHz) then    -- If Reset is low and rising edge of input clock
            if Counter_1kHz = Constant_for_1kHz - 1 then
                Clock_1kHz <= not Clock_1kHz;   -- If Counter for 250Hz has reached it max required value then invert the clock
            else
                Clock_1kHz <= Clock_1kHz;       -- otherwise let it be the same as previous value
            end if;
        end if;
    end process;
   
    ------------------------------------------------------------
    -- This Process Block rotates AN and outputs respective data
    ------------------------------------------------------------
    process(Clock_1kHz, Reset)  -- Sensitivity List 
    begin
        if Reset = '1' then     -- If Reset is high then set Data, Digit, Segment, and AN to their initial value
            data <= (others => '0');
            digit <= AN0;
            segment <= NUM(0);
            AN <= "1110";
        elsif rising_edge(Clock_1kHz) then  -- If Reset is low and rising edge of input clock
            data <= C1 & C0;                -- Combining C1 and C0 in one Data signal
            
            case digit is
                when AN0 =>                 -- If first digit lights up
                    segment <= NUM(to_integer(unsigned(data(3 downto 0))));
                    AN <= "1110";       -- Display C0(3 downto 0)
                    digit <= AN1;
                when AN1 =>                 -- If second digit lights up
                    segment <= NUM(to_integer(unsigned(data(7 downto 4))));
                    AN <= "1101";       -- Display C0(7 downto 4)
                    digit <= AN2;
                when AN2 =>                 -- If third digit lights up
                    segment <= NUM(to_integer(unsigned(data(11 downto 8))));
                    AN <= "1011";       -- Display C1(3 downto 0)
                    digit <= AN3;
                when AN3 =>                 -- If fourth digit lights up
                    segment <= NUM(to_integer(unsigned(data(15 downto 12))));
                    AN <= "0111";       -- Display C1(7 downto 4)
                    digit <= AN0;
                when others =>              -- Otherwise display 0 on first digit
                    segment <= NUM(0);
                    AN <= "1110";
                    digit <= AN0;
            end case;
        end if;
    end process;
    
    Seg <= segment;     -- Outputs the cathode signals
    
end Behavioral;