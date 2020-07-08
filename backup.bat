@echo off
@rem Script de Backup Alfresco
@rem requisitos: 7zip e alfresco

SET PGUSER=alfresco
SET PGPASSWORD=sejalivre
SET PGHOST=localhost
SET PGPORT=5432
SET PGDATABASE=alfresco
SET DESTDIR=E:\BackupAlfresco
SET CONTENTSTORE=D:\alf_data\contentstore
SET INDEX=D:\alf_data\solr4
SET KEYSTORE=D:\alf_data\keystore
SET ZIP7="C:\Program Files\7-Zip\7z.exe"
SET ALFRESCO=C:\alfresco\

@title Iniciando backup

FOR /F %%i IN ('cscript "%~dp0lastDay.vbs" //Nologo') do SET DATAREMOVE=%%i
echo Backup a excluir: %DATAREMOVE%

set "YYYY2=%DATAREMOVE:~6,4%" & set "MM2=%DATAREMOVE:~3,2%" & set "DD2=%DATAREMOVE:~0,2%"
set "DIAREMOVE=%YYYY2%%MM2%%DD2%"

e:
echo apagando pasta: %DESTDIR%\%DIAREMOVE%
del /q %DESTDIR%\%DIAREMOVE%
rmdir %DESTDIR%\%DIAREMOVE%
c:

@echo --------------------
@echo Iniciando Backup do PostgreSQL
@echo --------------------

@echo  Parando o servico do Tomcat...
net stop "alfrescoTomcat"

@cd C:\alfresco\postgresql\bin
@echo Acessando diretório do postgresql ...

@echo formatando data...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
echo datestamp: "%datestamp%"

mkdir %DESTDIR%\%datestamp%
pg_dump.exe --host %PGHOST% --port %PGPORT% --username %PGUSER% --format tar --file %DESTDIR%\%datestamp%\postgresql.backup %PGDATABASE%

@echo --------------------
@echo Concluido Backup do PostgreSQL
@echo --------------------

@echo --------------------
@echo Iniciando Backup do repositório
@echo --------------------

@d:
@cd %KEYSTORE%
@echo %KEYSTORE%

@cd %CONTENTSTORE%
%ZIP7% a -tzip %DESTDIR%\%datestamp%\contentstore.zip * -r

@cd %INDEX%
%ZIP7% a -tzip %DESTDIR%\%datestamp%\solr4.zip * -r

@c:
REM Backup do sistema a cada 3 dias ( rotacionando 3 em 3 o backup total )
SET "GRAVASOFTWARE=FALSE"

IF "%DD%" EQU "01" (
    SET "GRAVASOFTWARE=TRUE"
) ELSE (
	IF "%DD%" EQU "03" (
		SET "GRAVASOFTWARE=TRUE"
	) ELSE (
		IF "%DD%" EQU "06" (
			SET "GRAVASOFTWARE=TRUE"		
		) ELSE (
			IF "%DD%" EQU "09" (
				SET "GRAVASOFTWARE=TRUE"		
			) ELSE (
				IF "%DD%" EQU "12" (
					SET "GRAVASOFTWARE=TRUE"		
				) ELSE (
					IF "%DD%" EQU "15" (
						SET "GRAVASOFTWARE=TRUE"		
					) ELSE (
						IF "%DD%" EQU "18" (
							SET "GRAVASOFTWARE=TRUE"		
						) ELSE (	
							IF "%DD%" EQU "21" (
								SET "GRAVASOFTWARE=TRUE"		
							) ELSE (	
								IF "%DD%" EQU "24" (
									SET "GRAVASOFTWARE=TRUE"		
								) ELSE (								
									IF "%DD%" EQU "27" (
										SET "GRAVASOFTWARE=TRUE"		
									) ELSE (
										IF "%DD%" EQU "30" (
											SET "GRAVASOFTWARE=TRUE"		
										) ELSE (								
											SET "GRAVASOFTWARE=FALSE"					
										)	
									)	
								)
							)	
						)	
					)					
				)
			)	
		)
	)
)

IF "%GRAVASOFTWARE%" EQU "TRUE"  (
    @c:
    @echo Realizando backup do software alfresco...
    @cd %ALFRESCO%
    %ZIP7% a -tzip %DESTDIR%\%datestamp%\alfresco.zip * -r
   
    @d:
    %ZIP7% a -tzip %DESTDIR%\%datestamp%\keystore.zip * -r
	@echo %ZIP7%
	@echo diretorio destino
	@echo %DESTDIR%\%datestamp%\keystore.zip
)

@echo iniciando o servico do Tomcat...
net start "alfrescoTomcat"
@c:
@cd C:\alfresco\scripts
@echo --------------------
@echo Backup Concluido
@echo --------------------
