LIBRARY ieee  ; 
LIBRARY std  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_textio.all  ; 
USE ieee.STD_LOGIC_UNSIGNED.all  ; 
USE ieee.std_logic_unsigned.all  ; 
USE std.textio.all  ; 
ENTITY tb_Registers  IS 
END ; 
 
ARCHITECTURE tb_Registers_arch OF tb_Registers IS
  SIGNAL Cmd_Address   :  UNSIGNED (31 downto 0)  ; 
  SIGNAL AS_Address   :  std_logic_vector (2 downto 0)  ; 
  SIGNAL Reading   :  STD_LOGIC  ; 
  SIGNAL AcqAddress   :  UNSIGNED (31 downto 0)  ; 
  SIGNAL Cmd_Data   :  UNSIGNED (31 downto 0)  ; 
  SIGNAL Reset_n   :  STD_LOGIC  ; 
  SIGNAL AS_WriteData   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL Ack_Write   :  STD_LOGIC  ; 
  SIGNAL AS_ReadData   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL Clk   :  STD_LOGIC  ; 
  SIGNAL Currently_writing   :  STD_LOGIC  ; 
  SIGNAL Start   :  STD_LOGIC  ; 
  SIGNAL AS_Write   :  STD_LOGIC  ; 
  SIGNAL AcqBurstCount   :  UNSIGNED (2 downto 0)  ; 
  SIGNAL AS_ChipSelect   :  STD_LOGIC  ; 
  SIGNAL AS_Read   :  STD_LOGIC  ; 
  SIGNAL AcqLength   :  UNSIGNED (31 downto 0)  ; 
  COMPONENT Registers  
    PORT ( 
      Cmd_Address  : out UNSIGNED (31 downto 0) ; 
      AS_Address  : in std_logic_vector (2 downto 0) ; 
      Reading  : in STD_LOGIC ; 
      AcqAddress  : out UNSIGNED (31 downto 0) ; 
      Cmd_Data  : out UNSIGNED (31 downto 0) ; 
      Reset_n  : in STD_LOGIC ; 
      AS_WriteData  : in std_logic_vector (31 downto 0) ; 
      Ack_Write  : in STD_LOGIC ; 
      AS_ReadData  : out std_logic_vector (31 downto 0) ; 
      Clk  : in STD_LOGIC ; 
      Currently_writing  : out STD_LOGIC ; 
      Start  : out STD_LOGIC ; 
      AS_Write  : in STD_LOGIC ; 
      AcqBurstCount  : out UNSIGNED (2 downto 0) ; 
      AS_ChipSelect  : in STD_LOGIC ; 
      AS_Read  : in STD_LOGIC ; 
      AcqLength  : out UNSIGNED (31 downto 0) ); 
  END COMPONENT ; 
BEGIN
  DUT  : Registers  
    PORT MAP ( 
      Cmd_Address   => Cmd_Address  ,
      AS_Address   => AS_Address  ,
      Reading   => Reading  ,
      AcqAddress   => AcqAddress  ,
      Cmd_Data   => Cmd_Data  ,
      Reset_n   => Reset_n  ,
      AS_WriteData   => AS_WriteData  ,
      Ack_Write   => Ack_Write  ,
      AS_ReadData   => AS_ReadData  ,
      Clk   => Clk  ,
      Currently_writing   => Currently_writing  ,
      Start   => Start  ,
      AS_Write   => AS_Write  ,
      AcqBurstCount   => AcqBurstCount  ,
      AS_ChipSelect   => AS_ChipSelect  ,
      AS_Read   => AS_Read  ,
      AcqLength   => AcqLength   ) ; 



-- "Clock Pattern" : dutyCycle = 50
-- Start Time = 0 ns, End Time = 1 us, Period = 20 ns
  Process
	Begin
	 clk  <= '0'  ;
	wait for 20 ns ;
-- 10 ns, single loop till start period.
	for Z in 1 to 49
	loop
	    clk  <= '1'  ;
	   wait for 10 ns ;
	    clk  <= '0'  ;
	   wait for 10 ns ;
-- 990 ns, repeat pattern in loop.
	end  loop;
	 clk  <= '1'  ;
	wait for 10 ns ;
-- dumped values till 1 us
	wait;
 End Process;

Process
	Begin 					
      	 AS_ChipSelect <= '0' ; 
      	 AS_WriteData  <= (others => '0'); 
      	 Reset_n  <= '1' ; 
      	 AS_Address  <= (others => '0') ; 
         AS_Write  <= '0';
         AS_Read <= '0';
         Ack_write <= '0';

	wait for 20 ns ; 
	 
	  Reset_n  <= '0' ; 
	  AS_ChipSelect <= '1' ; 
	   	
	wait for 20 ns;                -- First, we are going to write the base address from where we want to read 
    	Reset_n  <= '1' ; 
    	AS_Write <= '1';
    	AS_Address  <= "000";       
    	AS_WriteData <= X"0000_0004";

  	wait for 40 ns;                -- Second, the length of lectures we want to do 
    	AS_Address  <= "001";       
    	AS_WriteData <= X"0000_0002";

  	wait for 60 ns;                -- Third, the burstcount we want to use 
    	AS_Address  <= "010";       
    	AS_WriteData <= X"0000_0004";

  	wait for 80 ns;                -- Fourth, enable/disable the reading process from SDRAM 
   	 AS_Address  <= "110";       
    	 AS_WriteData <= X"0000_0001";

	wait for 80 ns;                -- Fifth, cmd_address  
   	 AS_Address  <= "100";       
    	 AS_WriteData <= X"0000_0001";

	wait for 80 ns;                -- Sixth, cmd_data
   	 AS_Address  <= "101";       
    	 AS_WriteData <= X"0000_0001";
	
	wait for 90 ns;
	 AS_Write <= '0';		-- Now, we simulate the reading process
	 AS_Read <= '1';

	wait for 100 ns;	
	 AS_Address  <= "000"; 		-- Fist, the base address
	
	wait for 120 ns;	
	 AS_Address  <= "001"; 		--Second, the length

	wait for 140 ns;	
	 AS_Address  <= "010";  	--Fourth, the bourscount

	wait for 160 ns;	
	 AS_Address  <= "100";  	--Fifth, the cmd_address

	wait for 180 ns;	
	 AS_Address  <= "101";  	--Sixth, the cmd_data


	wait;
 End Process;
END;
