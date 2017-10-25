USE [Tesoreria]
GO
/****** Object:  StoredProcedure [dbo].[INS_APLICA_REFERENCIAS_SP]    Script Date: 10/25/2017 16:00:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[INS_APLICA_REFERENCIAS_SP]
	@idReferencia INT
AS
BEGIN
	DECLARE @idReferencianNueva INT,  @idBanco INT, @idBancoFinal INT, @Referencia VARCHAR(20)
	
	SET @idBanco = 1
	SET @idBancoFinal=1
	SET @Referencia = (SELECT [referencia] FROM [Tesoreria].[dbo].[Referencia] WHERE [idReferencia] = @idReferencia)

	IF(@idBanco = 1)
		BEGIN
			UPDATE [referencias].[dbo].[Bancomer] SET [referencia] = @Referencia, estatus = 1 WHERE [idBmer] = @idBancoFinal
		END
	ELSE
		BEGIN
			UPDATE [referencias].[dbo].[Santander] SET [referencia] = @Referencia, estatus = 1 WHERE [idSantander] = @idBancoFinal
		END

	INSERT INTO [referencias].[dbo].Referencia
	SELECT 
		   [idEmpresa]
		  ,[fecha]
		  ,[referencia]
		  ,[tipoReferencia]
		  ,[numeroConsecutivo]
		  ,[estatus]
	FROM [Tesoreria].[dbo].[Referencia]
	WHERE [idReferencia] = @idReferencia

	SET @idReferencianNueva = SCOPE_IDENTITY()

	INSERT INTO [referencias].[dbo].[DetalleReferencia]
	SELECT 
		   [idSucursal]
		  ,[idDepartamento]
		  ,[idTipoDocumento]
		  ,[importeDocumento]
		  ,[documento]
		  ,[idCliente]
		  ,[idAlmacen]
		  ,@idReferencianNueva
	FROM [Tesoreria].[dbo].[DetalleReferencia]
	WHERE [idReferencia] = @idReferencia

	UPDATE  [Tesoreria].[dbo].[Referencia] 
	SET [estatus] = 2 
	WHERE [idReferencia] = @idReferencia;
	
	-- Obtenemos si hay mas de una sucursal en el detalle
	DECLARE @SucVarios INT = (SELECT COUNT(DISTINCT(idSucursal)) Sucursal FROM [Tesoreria].[dbo].[Referencia] REF
	INNER JOIN [Tesoreria].[dbo].[DetalleReferencia] DET ON REF.idReferencia = DET.idReferencia
	WHERE REF.idReferencia = @idReferencia);
	
	DECLARE @idEmpresa INT = (SELECT idEmpresa FROM [Tesoreria].[dbo].[Referencia] WHERE [idReferencia] = @idReferencia);
	DECLARE @Cartera VARCHAR(255) = (SELECT '[' + ip_servidor + '].[' + nombre_base_matriz + '].dbo.VIS_CONCAR01' FROM [Centralizacionv2].[dbo].[DIG_CAT_BASES_BPRO] WHERE emp_idempresa = @idEmpresa AND tipo = 2);
	
	-- Se guarda el registro en refantipag
	DECLARE @Query NVARCHAR(MAX);
	SET @Query = 'INSERT INTO GA_Corporativa.dbo.cxc_refantypag 
					SELECT 
						rap_idempresa = REF.idEmpresa,
						rap_idsucursal = (CASE WHEN ' + CONVERT( VARCHAR(20),@SucVarios ) + ' = 1 THEN DET.idSucursal ELSE 3 END ),
						rap_iddepartamento = DET.idDepartamento,
						rap_idpersona = DET.idCliente,
						rap_cobrador = ''MMK'',
						rap_moneda = ''PE'',
						rap_tipocambio = 1,
						rap_referencia = '''',
						rap_iddocto =  DET.documento,	
						rap_cotped = '''',
						rap_consecutivo = (SELECT top 1 CCP_CONSCARTERA FROM '+ @Cartera +' WHERE CCP_VFDOCTO COLLATE Modern_Spanish_CS_AS = DET.documento AND CCP_IDDOCTO COLLATE Modern_Spanish_CS_AS= DET.documento AND CCP_IDPERSONA = DET.IdCliente),
						rap_importe = convert(decimal(32,2),DET.importeDocumento),
						rap_formapago = (select top 1 co.CodigoBPRO  from [referencias].[dbo].Bancomer b inner join  [referencias].[dbo].CodigoIdentificacion co  on co.CodigoBanco = b.codigoLeyenda),
						rap_numctabanc = SUBSTRING(txtOrigen,5,20),
						rap_fecha = GETDATE(),
						rap_idusuari = (SELECT top 1 usu_idusuario FROM ControlAplicaciones..cat_usuarios WHERE usu_nombreusu = ''GMI''),
						rap_idstatus = ''1'',
						rap_banco = C.IdBanco_bpro,
						rap_referenciabancaria = REF.referencia,
						rap_anno = (SELECT top 1 Vcc_Anno FROM '+ @Cartera +' WHERE CCP_VFDOCTO COLLATE Modern_Spanish_CS_AS = DET.documento  AND CCP_IDDOCTO COLLATE Modern_Spanish_CS_AS= DET.documento AND CCP_IDPERSONA = DET.IdCliente) 
					FROM [Tesoreria].[dbo].[DetalleReferencia] DET
					INNER JOIN [Tesoreria].[dbo].[Referencia] REF		ON DET.idReferencia = REF.idReferencia
					INNER JOIN Centralizacionv2..DIG_CAT_BASES_BPRO BP	ON REF.idEmpresa = BP.emp_idempresa AND DET.idSucursal = BP.suc_idsucursal
					INNER JOIN [Tesoreria].[dbo].[DepositoBancoView] B	ON REF.depositoID = B.idBmer
					INNER JOIN [referencias].[dbo].Rel_BancoCobro C		ON REF.idEmpresa = C.emp_idempresa AND B.idBanco = C.IdBanco
					WHERE REF.idReferencia = ' + CONVERT(VARCHAR(18), @idReferencia) ;
	EXEC( @Query );

	SELECT 1 idEstatus ,'SE APLICO REFERENCIA' descripcion
END
