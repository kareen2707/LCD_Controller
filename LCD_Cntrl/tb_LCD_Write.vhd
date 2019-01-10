LIBRARY ieee  ; 
LIBRARY std  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_textio.all  ; 
USE ieee.std_logic_unsigned.all  ; 
USE std.textio.all  ; 
ENTITY tb_LCD_Write  IS 
END ; 
 
ARCHITECTURE tb_LCD_Write_arch OF tb_LCD_Write IS
		Signal Clk	: std_logic;
		Signal Reset_n	 : std_logic;
		
		--Configuration registers
		Signal Write_Ack : std_logic;	--new_command
		Signal Cmd_Address : std_logic_vector(15 downto 0);
		Signal Cmd_Data : std_logic_vector(15 downto 0);
		Signal New_Cmd	: std_logic;
		--Signals connected to FIFO
		
		Signal FIFO_Empty	: std_logic;
		Signal Rd_FIFO		: std_logic_vector(31 downto 0);		
		
		--LCD Signals 
		Signal RGB_out		: std_logic_vector(15 downto 0);
		Signal CSX	: std_logic;
		Signal DCX	: std_logic;
		Signal WRX	: std_logic;
		Signal RDX	: std_logic;	--may or may not need, only for reading registers
  COMPONENT LCD_Write  
    PORT ( 
		Clk				:	in  std_logic;
		Reset_n				: 	in std_logic;
		
		--Configuration registers
		Write_Ack			:	out std_logic;	--new_command
		Cmd_Address			:	in std_logic_vector(15 downto 0);
		Cmd_Data			:	in std_logic_vector(15 downto 0);
		New_Cmd				:	in std_logic;
		--Signals connected to FIFO
		
		FIFO_Empty			:	in std_logic;
		Rd_FIFO				:	in std_logic_vector(31 downto 0);		
		
		--LCD Signals 
		RGB_out				: 	out std_logic_vector(15 downto 0);
		CSX				:	out std_logic;
		DCX				:	out std_logic;
		WRX				:	out std_logic;
		RDX				:	out std_logic	--may or may not need, only for reading registers
	); 
  END COMPONENT ; 
BEGIN
  DUT  : LCD_Write 
    PORT MAP ( 
		Clk	=> Clk,
		Reset_n	 => Reset_n,
		
		--Configuration registers
		Write_Ack	=> Write_Ack,
		Cmd_Address	=> Cmd_Address,
		Cmd_Data	=> Cmd_Data,
		New_Cmd		=> New_Cmd,

		--Signals connected to FIFO
		
		FIFO_Empty	=> FIFO_Empty,
		Rd_FIFO		=> Rd_FIFO,	
		
		--LCD Signals 
		RGB_out		=> RGB_out,
		CSX		=> CSX,
		DCX		=> DCX,
		WRX		=> WRX,
		RDX		=> RDX
	 ) ; 



-- "Clock Pattern" : dutyCycle = 50
-- Start Time = 0 ns, End Time = 1 us, Period = 20 ns
  Process
	Begin
	 clk  <= '0'  ;
	wait for 10 ns ;
-- 10 ns, single loop till start period.
	for Z in 1 to 49
	loop
	    clk  <= '1' ;
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


-- "Rest of signals"
-- Start Time = 0 ns, End Time = 1 us
  Process
  Begin
  Reset_n  <= '0' ; 
  
  --First load commands from the data when commands are recieved to the registers

  wait for 100 ns;
  Reset_n <= '1';
  wait for 100 ns;
  New_Cmd <= '1';
  Cmd_Address <= x"0050";
  Cmd_Data <= x"9605";
                      
	wait;
 End Process;
END;
