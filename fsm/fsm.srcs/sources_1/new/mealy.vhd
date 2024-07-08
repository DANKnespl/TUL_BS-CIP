library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mealy is
    Port(
        clk : in  std_logic;
        rst : in  std_logic;
        en  : in  std_logic;
        x   : in  std_logic;
        q   : out std_logic
    );
end mealy;

architecture Behavioral of mealy is
    type fsm_t is (SXXX, S1XX, S11X);
    
    signal current_state, next_state : fsm_t;
begin
    fsm_mem: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= SXXX;
            elsif en ='1' then
                current_state <= next_state;
            end if;
         end if;
    end process;
    
    fsm_transfer: process(current_state,x)
    begin
        next_state <= current_state;
        case current_state is
            when SXXX =>
                if x = '1' then
                    next_state <=S1XX;
                end if;
            when S1XX =>
                if x = '1' then
                    next_state <=S11X;
                    else
                    next_state <= SXXX;
                end if;
            when S11X =>
                if x = '0' then
                    next_state <= SXXX;
                end if;
            when others =>
                 next_state <= SXXX;
        end case;
    end process;
    
    process(current_state,x)
         begin
            case current_state is
                when S11X =>
                if x ='0' then
                    q <= '1';
                    else
                    q <= '0';
                end if;    
                when others => 
                    q <= '0';
            end case;
            end process;
end Behavioral;
