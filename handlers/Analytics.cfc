component {

// PUBLIC METHODS
	public any function triggerEvent( event, rc, prc ) {
		var args   = arguments.rc ?: {};
		var method = args.method  ?: "";

		if( !Len( trim( method ) ) ) {
			return;
		}

		if( method == "disableGamp" ) {
			structDelete( "prc", "_analytics" );
			return;
		}

		if ( !prc.keyExists( "_analytics" ) ) {
			return;
		}

		return prc._analytics[ method ]( argumentCollection=args );
	}

}