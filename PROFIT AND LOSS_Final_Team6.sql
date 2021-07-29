USE H_Accounting;
DROP PROCEDURE IF EXISTS team6_sp;

-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$

	CREATE PROCEDURE team6_sp (varCalendarYear YEAR)
	BEGIN
  
		-- We can define all variables inside of procedure
		DECLARE varTotalRevenues, 
				varTotalCOSG, 
				varTotalOEXP, 
				varTotalSEXP, 
				varTotalOI, 
				varTotalINCTAX DOUBLE DEFAULT 0;
  
		--  REVENUE
		SELECT SUM(jeli.credit) INTO varTotalRevenues
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "REV"
				AND YEAR(je.entry_date) = varCalendarYear;
		
        -- COST OF GOOD SOLD
        SELECT SUM(jeli.credit) INTO varTotalCOSG
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "COGS"
				AND YEAR(je.entry_date) = varCalendarYear;
		 
         -- OTHER EXPENSES
         SELECT SUM(jeli.credit) INTO varTotalOEXP
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "OEXP"
				AND YEAR(je.entry_date) = varCalendarYear;
		
        -- SELLING EXPENSES
        SELECT SUM(jeli.credit) INTO varTotalSEXP
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "SEXP"
				AND YEAR(je.entry_date) = varCalendarYear;
	
		-- INCOME TAX
         SELECT SUM(jeli.credit) INTO varTotalINCTAX
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "INCTAX"
				AND YEAR(je.entry_date) = varCalendarYear;
                
		-- OTHER INCOME
         SELECT SUM(jeli.credit) INTO varTotalOI 
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
			
            
			WHERE ss.statement_section_code = "OI"
			AND YEAR(je.entry_date) = varCalendarYear;
		
        
		-- CREATE THE TABLE (DROP IT FIRST)
		DROP TABLE IF EXISTS tmp_team6_table;
  
		-- TABLE CONTAINS ALL RESULTS
		CREATE TABLE tmp_team6_table
		( Profit_loss_line_number INT, 
			Label VARCHAR(50), 
			Amount VARCHAR(50)
		);
  
		-- INSERT EACH ROW
        -- TITLE OF EACH COLUMN IN THE TABLE
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (1, 'PROFIT AND LOSS STATEMENT', "In '000s of USD");
		
        INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (2, varCalendarYear, "");
            
		-- EMPTY LINE
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (3, '', '');
		
		-- TOTAL REVENUES
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (4, '   Total Revenues', format(varTotalRevenues / 1000, 2));
            
		-- TOTAL COST OF GOOD SOLD
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (5, '   Total COGS', format(varTotalCOSG/1000, 2));
		
        -- GROSS MARGIN = TOTAL REVENUE - COGS
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (6, 'Gross Margin', format((varTotalRevenues - varTotalCOSG)/1000, 2));
		
        -- OTHER EXPENSES
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (7, '   Total Other Expenses', format(varTotalOEXP /1000, 2));
		
        -- SELLING EXPENSES
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (8, '   Total Selling Expenses', format(varTotalSEXP/1000, 2));
		
        -- TOTAL EXPENSES = OTHER EXPENSES + SELLING EXPENSES
        INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (9, 'Total Expenses', format((varTotalOEXP + varTotalSEXP)/1000, 2));
		
        -- PROFIT BEFORE TAX = GROSS MARGIN - TOTAL EXPENSES
        INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (10, 'Profit Before Tax', format(((varTotalRevenues - varTotalCOSG) -(varTotalOEXP +varTotalSEXP))/1000, 2));
         
		-- TOTAL INCOME TAXES
        INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (11, '   Total Income Taxes', format(IFNULL(varTotalINCTAX,0)/1000, 2));
		
        -- TOTAL OTHER INCOME
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (12, '   Total Other Income', format(IFNULL(varTotalOI,0)/1000, 2));
		
		-- PROFIT/LOSS = TOTAL OTHER INCOME + PROFIT BEFORE TAXES - TOTAL INCOME TAXES
		INSERT INTO tmp_team6_table
			(profit_loss_line_number, label, amount)
			VALUES (13, 'PROFIT/LOSS', format(((varTotalRevenues - varTotalCOSG - varTotalOEXP - IFNULL(varTotalSEXP,0)) + IFNULL(varTotalOI,0) - IFNULL(varTotalINCTAX,0))/1000, 2));
		END $$

DELIMITER ;

CALL team6_sp (2018);

SELECT * FROM tmp_team6_table;

