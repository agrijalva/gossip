USE [referencias]
GO
/****** Object:  StoredProcedure [dbo].[INS_CXC_FROMLAYOUT_BANCOMER_SP]    Script Date: 10/25/2017 15:53:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alejandro Grijalva Antonio
/*
SELECT TOP 2 * FROM GA_Corporativa.dbo.cxc_refantypag WHERE rap_idstatus = 1 ORDER BY rap_folio ASC;
EXECUTE [INS_CXC_FROMLAYOUT_BANCOMER_SP] 1;
*/

-- =============================================


CREATE PROCEDURE [dbo].[INS_CXC_FROMLAYOUT_BANCOMER_SP]
	@idEmpresa INT
AS
BEGIN
	DECLARE @FacturaQuery varchar(max)       = '';
	DECLARE @CotizacionQuery varchar(max)    = '';
	DECLARE @base VARCHAR(250);
	DECLARE @idSuc varchar(max);
	
	-- Consulta de las bases de datos y sucursales activas
	DECLARE @tableConf  TABLE(idEmpresa INT, idSucursal INT, servidor VARCHAR(250), baseConcentra VARCHAR(250), sqlCmd VARCHAR(8000), cargaDiaria VARCHAR(8000));
	INSERT INTO @tableConf Execute [dbo].[SEL_ACTIVE_DATABASES_SP];

	-- Creación de cursor
	DECLARE Sucursales_Cursor CURSOR FOR 
		SELECT servidor , convert(varchar(max),idSucursal)
		FROM @tableConf 
		WHERE idEmpresa = @idEmpresa
	OPEN Sucursales_Cursor
    
	FETCH NEXT FROM Sucursales_Cursor INTO @base, @idSuc

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		SELECT @FacturaQuery       = [dbo].[ufnGetReferenciaFacturaString](@base, @idEmpresa, @idSuc);
		EXEC(@FacturaQuery)
		PRINT @FacturaQuery
			
		
		SELECT @CotizacionQuery    = [dbo].[ufnGetReferenciaCotizacionString](@base, @idEmpresa, @idSuc);		
		EXEC(@CotizacionQuery)
		PRINT @CotizacionQuery
		
		FETCH NEXT FROM Sucursales_Cursor INTO @base, @idSuc
	END
	CLOSE Sucursales_Cursor;  
	DEALLOCATE Sucursales_Cursor; 
	
	-- ACTUALIZAMOS LOS REGISTROS QUE SE HAN REVISADO Y AQUELLOS QUE NO NO SE CONTROLAN EN ESTE MOMENTO
	UPDATE Bancomer SET estatusRevision = 2 WHERE estatusRevision = 1;
	UPDATE Bancomer SET estatus = 4 WHERE noCuenta ='000000000190701289' AND estatus <> 4;
END

