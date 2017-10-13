<?php
class Usuario
{
	var $Return_Type;
	var $conn;

	var $edad;
	var $genero;

	var $edadMin;
    var $edadMax;
    var $rango;

    var $idUsuario;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function registro(){
		$_response['success'] = false;
		if( empty( $this->edad ) && empty( $this->genero ) ){
			$_response['msg']     	= 'Favor de proporcionar lo solicitado';
		}
		else if( empty( $this->edad ) ){
			$_response['msg']     	= 'Proporciona tu edad';
		}
		else if( empty( $this->genero ) ){
			$_response['msg']     	= 'Proporciona tu sexo';
		}
		else{
			$params = array(
					'genero' => array( 'value' => $this->genero, 'type' => 'INT' ),
					'edad'   => array( 'value' => $this->edad,   'type' => 'INT' )					
				);

			$_result = $this->conn->Query( "USU_INS_NUEVO_SP", $params );

			if( !empty( $_result ) ){
				$_response['success'] = true;
				$_response['msg']     = 'Nuevo usuario registrado';
				$_response['data']	  = $_result;
			}
			else{
				$_response['msg']     	= 'No se encontraron resultados para tu solicitud.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function updateSettings(){
		$_response['success'] = false;
		if( empty( $this->idUsuario ) ){
			$_response['msg']     	= 'Favor de proporcionar el id del usuario';
		}
		else if( empty( $this->edadMin ) ){
			$_response['msg']     	= 'Favor de proporcionar la edad minima';
		}
		else if( empty( $this->edadMax ) ){
			$_response['msg']     	= 'Favor de proporcionar la edad maxima';
		}
		else if( empty( $this->genero ) ){
			$_response['msg']     	= 'Proporciona tu sexo';
		}
		else if( empty( $this->rango ) ){
			$_response['msg']     	= 'Proporciona tu sexo';
		}
		else{
			$params = array(
					'_edadMin' => array( 'value' => $this->edadMin, 'type' => 'INT' ),
					'_edadMax' => array( 'value' => $this->edadMax, 'type' => 'INT' ),
					'_genero'  => array( 'value' => $this->genero,  'type' => 'INT' ),
					'_rango'   => array( 'value' => $this->rango,   'type' => 'INT' ),
					'idUsu'    => array( 'value' => $this->idUsuario,   'type' => 'INT' )
				);

			$_result = $this->conn->Query( "STT_UPD_CONFIGURACION_SP", $params );

			if( !empty( $_result ) ){
				$_response['success'] = true;
				$_response['msg']     = 'Configuracion actualizada';
				$_response['data']	  = $_result;
			}
			else{
				$_response['msg']     	= 'No se encontraron resultados para tu solicitud.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	private function Assign_Properties_Values($Properties_Array){
		if (is_array($Properties_Array)) {
			foreach($Properties_Array as $Property_Name => $Property_Value)  {
				$this->{$Property_Name} = trim(htmlentities($Property_Value, ENT_QUOTES, 'UTF-8'));
			}
		}
	}

	private function Request( $_array ){
		if( empty( $this->Return_Type ) ){
			return $_array;			
		}
		else if( $this->Return_Type == 'json'  || $this->Return_Type == 'JSON' ){
			print_r( json_encode( $_array ) );
		}
	}
}
?>