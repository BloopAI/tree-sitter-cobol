       IDENTIFICATION              DIVISION.
      ******************************************************************
       PROGRAM-ID.                 prog.
      ******************************************************************
       DATA                        DIVISION.
      ******************************************************************
       WORKING-STORAGE             SECTION.
       01 TEST-CASE-COUNT PIC 9999 VALUE 1.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DBNAME                  PIC  X(30) VALUE SPACE.
       01  USERNAME                PIC  X(30) VALUE SPACE.
       01  PASSWD                  PIC  X(10) VALUE SPACE.
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.
      ******************************************************************
       PROCEDURE                   DIVISION.
      ******************************************************************
       MAIN-RTN.
           
      *    SERVER
           MOVE  "<|DB_NAME|>@<|DB_HOST|>:<|DB_PORT|>"
             TO DBNAME.
           MOVE  "<|DB_USER|>"
             TO USERNAME.
           MOVE  "<|DB_PASSWORD|>"
             TO PASSWD.

           EXEC SQL
               CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME 
           END-EXEC.
           PERFORM DISPLAY-TEST-RESULT.

           EXEC SQL
              DISCONNECT ALL
           END-EXEC.
           PERFORM DISPLAY-TEST-RESULT.

      *    END
           STOP RUN.

      ******************************************************************
       DISPLAY-TEST-RESULT.
      ******************************************************************
           IF  SQLCODE = ZERO
             THEN
               DISPLAY "<log> test case " TEST-CASE-COUNT ": success"
               ADD 1 TO TEST-CASE-COUNT

             ELSE
               DISPLAY "*** SQL ERROR ***"
               DISPLAY "SQLCODE: " SQLCODE " " NO ADVANCING
               EVALUATE SQLCODE
                  WHEN  +10
                     DISPLAY "Record not found"
                  WHEN  -01
                     DISPLAY "Connection falied"
                  WHEN  -20
                     DISPLAY "Internal error"
                  WHEN  -30
                     DISPLAY "PostgreSQL error"
                     DISPLAY "ERRCODE: "  SQLSTATE
                     DISPLAY SQLERRMC
                  *> TO RESTART TRANSACTION, DO ROLLBACK.
                     EXEC SQL
                         ROLLBACK
                     END-EXEC
                  WHEN  OTHER
                     DISPLAY "Undefined error"
                     DISPLAY "ERRCODE: "  SQLSTATE
                     DISPLAY SQLERRMC
               END-EVALUATE
               STOP RUN.
      ******************************************************************  
