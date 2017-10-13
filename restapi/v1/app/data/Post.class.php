<?php
class Post
{
	var $Return_Type;
	var $conn;

	var $gossip;
    var $latitud;
    var $longitud;
    var $idUsuario;
	

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function NewGossip(){
		$_response['success'] = false;
		if( empty( $this->gossip ) ){
			$_response['msg']     = 'Proporcina el post';	
		}
		else if( empty( $this->latitud ) ){
			$_response['msg']     = 'Proporcina la latitud';	
		}
		else if( empty( $this->longitud ) ){
			$_response['msg']     = 'Proporcina la longitud';	
		}
		else if( empty( $this->idUsuario ) ){
			$_response['msg']     = 'Proporcina el id del usuario';	
		}
		else{
			$params = array(
				'gossip' 	=> array( 'value' => $this->gossip, 'type' => 'STRING' ),
				'latitud' 	=> array( 'value' => $this->latitud, 'type' => 'INT' ),
				'longitud' 	=> array( 'value' => $this->longitud, 'type' => 'INT' ),
				'idUsuario' => array( 'value' => $this->idUsuario, 'type' => 'INT' )
			);

			$_result = $this->conn->Query( "POST_INS_NEWGOSSIP_SP", $params );
			if( empty( $_result ) ){
				$_response['msg']     = 'Post no guardado';	
			}
			else{
				$_response = $_result[0];
			}
		}

		return $this->Request( $_response );
	}

	public function ByLocation(){
		$_response['success'] = false;
		if( empty( $this->latitud ) ){
			$_response['msg']     = 'Proporcina la latitud';	
		}
		else if( empty( $this->longitud ) ){
			$_response['msg']     = 'Proporcina la longitud';	
		}
		else if( empty( $this->idUsuario ) ){
			$_response['msg']     = 'Proporcina el id del usuario';	
		}
		else{
			$params = array(
				'latitud' 	=> array( 'value' => $this->latitud, 'type' => 'INT' ),
				'longitud' 	=> array( 'value' => $this->longitud, 'type' => 'INT' ),
				'idUsuario' => array( 'value' => $this->idUsuario, 'type' => 'INT' )
			);

			$_result = $this->conn->Query( "POST_SEL_BYLOCATION_SP", $params );
			if( empty( $_result ) ){
				$_response['msg']     = 'Post no encontrados';	
			}
			else{
				$_response['success'] = true;
				$_response['msg']     = 'Numero de post: ' . count($_result) ;
				$_response['data']	  = $_result;
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