library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    port(
        clk : in std_logic; -- 100 MHz clock
        rstn : in std_logic; -- Red CPU_RESETN (negative reset)
        btnl, btnr, btnu, btnd, btnc : in std_logic; -- Cross buttons
        SW : in std_logic_vector(15 downto 0); -- Switches
        LED : out std_logic_vector(15 downto 0)        
    );
end top;

architecture Behavioral of top is
    
    signal enable : std_logic;
    signal rst : std_logic;

begin

    -- dont like negative reset
    rst <= not rstn;

    -- button debounce (100/second button risign edge detection)
    enable_button_debounce : entity work.pulse
        port map(
            clk => clk,
            btn => btnl,
            pulse => enable
        );
        
    -- insert counter here
    
end Behavioral;
