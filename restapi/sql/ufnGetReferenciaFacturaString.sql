USE [referencias]
GO
/****** Object:  UserDefinedFunction [dbo].[ufnGetReferenciaFacturaString]    Script Date: 10/25/2017 15:59:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[ufnGetReferenciaFacturaString](@CurrentBase varchar(50), @idEmpresa varchar(2), @idSucursal varchar(2))  
RETURNS varchar(max)   
AS   
-- Returns the stock level for the product.  
BEGIN  
		declare @queryText varchar(max) = 
		'INSERT INTO GA_Corporativa.dbo.cxc_refantypag '+ char(13) + -- DESCOMENTAR LINEA
		'SELECT' + char(13) + 
		'	rap_idempresa		= R.idEmpresa,' + char(13) + 
		'	rap_idsucursal		= DR.idSucursal,' + char(13) + 
		'	rap_iddepartamento	= DR.idDepartamento,' + char(13) + 
		'	rap_idpersona		= DR.idCliente,' + char(13) + 
		'	rap_cobrador		= '+char(39)+'MMK'+char(39)+',' + char(13) + 
		'	rap_moneda			= '+char(39)+'PE'+char(39)+',' + char(13) + 
		'	rap_tipocambio		= 1,' + char(13) + 
		'	rap_referencia		= ltrim(B.refAmpliada) COLLATE SQL_Latin1_General_CP1_CI_AS,' + char(13) + 
		'	rap_iddocto			=  dr.documento,'+ 
		'	rap_cotped			= '+char(39)+''+char(39)+',' + char(13) + 		
		'	rap_consecutivo		= (SELECT CCP_CONSCARTERA FROM '+ @CurrentBase +'.VIS_CONCAR01 WHERE CCP_TIPODOCTO = ''FAC'' AND CCP_IDDOCTO COLLATE Modern_Spanish_CS_AS= DR.documento AND CCP_IDPERSONA = DR.IdCliente),' + char(13) + 
		'	rap_importe			= convert(numeric(18,2),b.importe),' + char(13) + 
		'	rap_formapago		= (select top 1 co.CodigoBPRO  from Bancomer b inner join  CodigoIdentificacion co  on co.CodigoBanco = b.codigoLeyenda where SUBSTRING(b.concepto,3,20) =  R.referencia),' + char(13) + 
		'	rap_numctabanc		= SUBSTRING(txtOrigen,5,20),' + char(13) + 
		'	rap_fecha			= GETDATE(),' + char(13) + 
		'	rap_idusuari		= (SELECT usu_idusuario FROM ControlAplicaciones..cat_usuarios WHERE usu_nombreusu = '+char(39)+'GMI'+char(39)+'),' + char(13) + 
		'	rap_idstatus		= '+char(39)+'1'+char(39)+',' + char(13) + 
		'	rap_banco			= C.IdBanco_bpro,' + char(13) + 
		'	rap_referenciabancaria	= R.referencia,' + char(13) + 	  
		'	rap_anno				= (SELECT Vcc_Anno FROM '+ @CurrentBase +'.VIS_CONCAR01 WHERE CCP_TIPODOCTO = ''FAC'' AND CCP_IDDOCTO COLLATE Modern_Spanish_CS_AS= DR.documento AND CCP_IDPERSONA = DR.IdCliente) ' + char(13) + 
		'FROM Referencia R ' + char(13) + 
		'INNER JOIN Bancomer							B		ON	R.Referencia = SUBSTRING(b.concepto,3,20)' + char(13) + 
		'INNER JOIN Centralizacionv2..DIG_CAT_BASES_BPRO BP		ON	R.idEmpresa = BP.emp_idempresa ' + char(13) + 
		'INNER JOIN Rel_BancoCobro						 C		ON	R.idEmpresa = C.emp_idempresa' + char(13) + 
		'INNER JOIN DetalleReferencia					 DR		ON	DR.idReferencia = R.idReferencia AND DR.idSucursal = BP.suc_idsucursal' + char(13) + 
		'WHERE B.estatusRevision = 1 ' + char(13) + 
		'	   AND B.esCargo = 0 ' + char(13) + 
		'	   AND DR.idTipoDocumento = 1' + char(13) + 
		'	   AND C.IdBanco = 1' + char(13) +
		'	   AND R.idEmpresa = ' + @idEmpresa + char(13) + 
		'	   AND DR.idSucursal = ' + @idSucursal + char(13)

    RETURN @queryText
END;  


