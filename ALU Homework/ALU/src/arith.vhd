library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;

entity arith is
    generic(
        C_WIDTH : integer := 8
    );
    port(
        -- output is registered
        clk             : in  std_logic;
        -- operands
        operandA        : in  std_logic_vector(C_WIDTH - 1 downto 0);
        operandB        : in  std_logic_vector(C_WIDTH - 1 downto 0);
        -- opcodes + input flags
        opcode          : in  opcode_t;
        -- input is signed
        opcode_signed   : in  std_logic;
        -- do saturated arithmetic   
        opcode_saturate : in  std_logic;
        -- result of operation
        result          : out std_logic_vector(C_WIDTH - 1 downto 0);
        -- output carry
        carry           : out std_logic;
        -- overflow occured
        overflow        : out std_logic;
        -- output is zero
        zero            : out std_logic;
        -- output was saturated
        saturated       : out std_logic
    );
end entity;

architecture RTL of arith is 
begin

	process(clk)
		variable process_result : std_logic_vector(C_WIDTH downto 0) := (others => '0');
		variable tmp : std_logic_vector(C_WIDTH*2-1 downto 0) := (others => '0');
	begin
		
		if rising_edge(clk) then
			
	--Reset flagu
			process_result := (others => '0');
			case opcode is
				
	--Sèítání
				when OAdd =>
					if opcode_signed = '0' then
						process_result := std_logic_vector(('0' & unsigned(operandA)) + ('0' & unsigned(operandB)));
						carry <= process_result(C_WIDTH); 
						if opcode_saturate = '1' and process_result(C_WIDTH) = '1' then
							saturated <= '1';
							process_result := (others => '1'); 
						elsif  opcode_saturate = '1' then
							saturated <= '0';
						else
							saturated <= 'U';
						end if;
					else
						carry <= 'U';
						process_result := std_logic_vector((operandA(C_WIDTH-1) & signed(operandA)) + (operandB(C_WIDTH-1) & signed(operandB)));
						if operandA(C_WIDTH-1) = operandB(C_WIDTH-1) and operandA(C_WIDTH-1) /= process_result(C_WIDTH-1) then
							overflow<='1';
							if opcode_saturate = '1' then
								process_result(C_WIDTH-1 downto 0) := operandA(C_WIDTH-1) & (C_WIDTH-2 downto 0 => not(operandA(C_WIDTH-1)));
								saturated <= '1';
							end if;
						else
							overflow<='0';
							saturated <= '0';
						end if;
						
						
					end if;
					
	--Odèítání
                when OSub =>
					if opcode_signed = '0' then
						process_result := std_logic_vector(('0' & unsigned(operandA)) - ('0' & unsigned(operandB)));
						carry <= process_result(C_WIDTH);  
						if opcode_saturate = '1' and process_result(C_WIDTH) = '1' then
							saturated <= '1';
							process_result(C_WIDTH downto 0) := (others => '0'); 
						elsif  opcode_saturate = '1' then
							saturated <= '0';
						else
							saturated <= 'U';
						end if;
					else								 
						carry <= 'U';
						process_result := std_logic_vector((operandA(C_WIDTH-1) & signed(operandA)) - (operandB(C_WIDTH-1) & signed(operandB)));
						if operandA(C_WIDTH-1) /= operandB(C_WIDTH-1) and operandB(C_WIDTH-1) = process_result(C_WIDTH-1) then
							overflow<='1';
							if opcode_saturate = '1' then
								process_result(C_WIDTH-1 downto 0) := operandA(C_WIDTH-1) & (C_WIDTH-2 downto 0 => not(operandA(C_WIDTH-1)));
								saturated <= '1';
							end if;
						else
							overflow<='0';
							saturated <= '0';
						end if;
					end if;
					
	--Násobení	
				when OMulH =>													   
					if opcode_signed = '0' then
						tmp:= std_logic_vector(unsigned(operandA)*unsigned(operandB));
						overflow <= 'U';
						carry <= '0';
					else
						tmp:= std_logic_vector(signed(operandA)*signed(operandB));
						carry <= 'U';
						if (operandA(C_WIDTH-1) /= operandB(C_WIDTH-1) and tmp(C_WIDTH*2-1) = '0')or(operandA(C_WIDTH-1) = operandB(C_WIDTH-1) and tmp(C_WIDTH*2-1) = '1') then
							overflow<= '1';
						else
							overflow<='0';
						end if;
					end if;
					process_result(C_WIDTH-1 downto 0) := tmp(C_WIDTH*2-1 downto C_WIDTH);
					
                when OMulL =>
					tmp:= std_logic_vector(unsigned(operandA)*unsigned(operandB));
					process_result(C_WIDTH-1 downto 0) := tmp(C_WIDTH-1 downto 0);

	--Posun
				when OShiftLeft =>
					process_result(C_WIDTH-1 downto 0) := std_logic_vector(shift_left(unsigned(operandA), to_integer(unsigned(operandB))));							
                when OShiftRight =>					
					process_result(C_WIDTH-1 downto 0)  := std_logic_vector(shift_right(unsigned(operandA), to_integer(unsigned(operandB))));

	--Rotace
                when ORotateLeft =>	  			
 					process_result(C_WIDTH-1 downto 0)  := std_logic_vector(rotate_left(unsigned(operandA), to_integer(unsigned(operandB))));
				when ORotateRigth =>
					process_result(C_WIDTH-1 downto 0)  := std_logic_vector(rotate_right(unsigned(operandA), to_integer(unsigned(operandB))));
		
	--Logické Funkce
                when ONot =>
                    process_result(C_WIDTH-1 downto 0)  := not operandA;
                when OAnd =>
                    process_result(C_WIDTH-1 downto 0)  := operandA and operandB;
                when OOr =>
                    process_result(C_WIDTH-1 downto 0)  := operandA or operandB;
                when OXor =>
					process_result(C_WIDTH-1 downto 0)  := operandA xor operandB;
	--Dìlení
				when ODiv =>   
					if opcode_signed = '0' then
						process_result(C_WIDTH-1 downto 0) := std_logic_vector(unsigned(operandA) / unsigned(operandB));
						carry <= '0';
						overflow <= 'U';
					else
						process_result(C_WIDTH-1 downto 0) := std_logic_vector(signed(operandA) / signed(operandB));		
						carry <= 'U';
						if (operandA(C_WIDTH-1) /= operandB(C_WIDTH-1) and process_result(C_WIDTH-1) = '0')or(operandA(C_WIDTH-1) = operandB(C_WIDTH-1) and process_result(C_WIDTH-1) = '1') then
							overflow<= '1';
						else
							overflow<='0';
						end if;
					end if;
                when OMod =>
					if opcode_signed = '0' then
						process_result(C_WIDTH-1 downto 0) := std_logic_vector(unsigned(operandA) mod unsigned(operandB));
					else	   
						process_result(C_WIDTH-1 downto 0) := std_logic_vector(signed(operandA) mod signed(operandB));
					end if;
				when others =>
					process_result := (others => '0');
			end case;
						
   	--Nastaveni flagu
	   
	   		if opcode = OMulL or opcode = OShiftLeft or opcode = OShiftRight or opcode = ORotateLeft or opcode = ORotateRigth or opcode = ONot or opcode = OAnd or opcode = OOr or opcode = OXor or opcode = OMod then
			   if opcode_signed = '0' then 		
				   	carry <= '0';
					overflow <= 'U';
			   else 
				   carry <= 'U';
				   overflow <= '0';
				end if;
			end if;
			
			
			if process_result(C_WIDTH-1 downto 0) = ((C_WIDTH-1 downto 0 => '0')) then
				zero <= '1';
			else 
				zero <= '0';
			end if;
			if (opcode /= OAdd and opcode /= OSub) and opcode_saturate = '1' then
				saturated <= '0';
			elsif opcode_saturate = '0' then
				saturated <= 'U';
			end if;
			result <= process_result(C_WIDTH - 1 downto 0);
			
		end if;
	end process;	
end architecture RTL;
