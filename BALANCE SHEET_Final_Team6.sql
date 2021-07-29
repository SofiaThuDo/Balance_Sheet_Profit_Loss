USE H_Accounting;
DROP PROCEDURE IF EXISTS team6_sp;

DELIMITER $$

	CREATE PROCEDURE team6_sp (varCalendarYear YEAR)
	BEGIN
  
		-- We can define all variables inside of procedure
		DECLARE varCrCA, varDeCA, 
				varCrFA, varDeFA,
                varCrCL, varDeCL,
                varCrEQ, varDeEQ DOUBLE DEFAULT 0;
  
		--  CREDIT CURRENT ASSETS
		SELECT SUM(jeli.credit) INTO varCrCA
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 	AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
      
			WHERE ss.statement_section_code = "CA"
				AND je.debit_credit_balanced = 1
				AND ss.statement_section_id <> 0
				AND YEAR(je.entry_date) <= varCalendarYear;
                
		-- DEBIT CURRENT ASSETS
        SELECT SUM(jeli.debit) INTO varDeCA
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 	AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
      
			WHERE ss.statement_section_code = "CA"
				AND je.debit_credit_balanced = 1
				AND ss.statement_section_id <> 0
				AND YEAR(je.entry_date) <= varCalendarYear;
        
        -- CREDIT FIXED ASSETS
        SELECT SUM(jeli.credit) INTO varCrFA
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
      
			WHERE ss.statement_section_code = "FA"
				AND je.debit_credit_balanced = 1
				AND ss.statement_section_id <> 0
				AND YEAR(je.entry_date) <= varCalendarYear;
		
        -- DEBIT FIXED ASSETS
        SELECT SUM(jeli.debit) INTO varDeFA
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
      
			WHERE ss.statement_section_code = "FA"
				AND je.debit_credit_balanced = 1
				AND ss.statement_section_id <> 0
				AND YEAR(je.entry_date) <= varCalendarYear; 
         
		
        -- CREDIT CURRENT LIABILITIES
        SELECT SUM(jeli.credit) INTO varCrCL
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
      
			WHERE ss.statement_section_code = "CL"
				AND je.debit_credit_balanced = 1
				AND ss.statement_section_id <> 0
				AND YEAR(je.entry_date) <= varCalendarYear;
		
        -- DEBIT CURRENT LIABILITY
        SELECT SUM(jeli.debit) INTO varDeCL
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
      
			WHERE ss.statement_section_code = "CL"
				AND je.debit_credit_balanced = 1
				AND ss.statement_section_id <> 0
				AND YEAR(je.entry_date) <= varCalendarYear;
                
		-- CREDIT EQUITY
		SELECT SUM(IFNULL(jeli.credit,0)) INTO varCrEQ
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
      
			WHERE ss.statement_section_code = "EQ"
				AND je.debit_credit_balanced = 1
				AND ss.statement_section_id <> 0
				AND YEAR(je.entry_date) <= varCalendarYear;
		
        -- DEBIT EQUITY
		SELECT SUM(IFNULL(jeli.debit,0)) INTO varDeEQ
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
      
			WHERE ss.statement_section_code = "EQ"
				AND je.debit_credit_balanced = 1
				AND ss.statement_section_id <> 0
				AND YEAR(je.entry_date) <= varCalendarYear;
		 
		-- CREATE THE TABLE (DROP IT FIRST)
		DROP TABLE IF EXISTS tmp_team6_table;
  
		-- TABLE CONTAINS ALL RESULTS
		CREATE TABLE tmp_team6_table
		( balance_sheet_line_number INT, 
			label_a VARCHAR(50), 
			amount_a VARCHAR(50),
            label_p VARCHAR(50), 
			amount_p VARCHAR(50)
		);
  
  -- INSERT EACH ROW TO THE TABLE
  INSERT INTO tmp_team6_table
		(balance_sheet_line_number, label_a, amount_a, label_p, amount_p)
		VALUES (1, 'BALANCE SHEET', varCalendarYear - 1, '', '');
  
  -- TITLE OF EACH COLUMNS
	INSERT INTO tmp_team6_table
		(balance_sheet_line_number, label_a, amount_a, label_p, amount_p)
		VALUES (2, 'Assets', "In '000s of USD", 'Liabilities', "In '000s of USD" );
	
    -- EMPTY LINE
      INSERT INTO tmp_team6_table
		(balance_sheet_line_number, label_a, amount_a, label_p, amount_p)
		VALUES (3, " ", " ", " ", " ");
    
    -- CURRENT ASSETS & CURRENT LIABILITIES
	INSERT INTO tmp_team6_table
		(balance_sheet_line_number, label_a, amount_a, label_p, amount_p)
		VALUES (4, 'Current Assets',  format((varDeCA-varCrCA)/1000,2), 'Current Liabilities',format((varCrCL-varDeCL)/1000,2) );
	
    -- FIXED ASSETS & EQUITY
    INSERT INTO tmp_team6_table
		(balance_sheet_line_number, label_a, amount_a, label_p, amount_p)
		VALUES (5, 'Fixed Asset', format((varCrFA-varDeFA)/1000,2), 'Equity', format((varCrEQ-varDeEQ)/1000,2));
    
    -- TOTAL ASSETS & TOTAL LIABILITIES
    INSERT INTO tmp_team6_table
		(balance_sheet_line_number, label_a, amount_a, label_p, amount_p)
		VALUES (6, 'Total Assets', format(((varDeCA-varCrCA)+(varCrFA-varDeFA))/1000,2), 
        'Total Liabilities & Equity', format(((varCrCL-varDeCL)+(varCrEQ-varDeEQ))/1000,2));
   
    END $$

DELIMITER ;


CALL team6_sp (2018);

SELECT * FROM tmp_team6_table;