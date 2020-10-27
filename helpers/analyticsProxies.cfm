<cffunction name="analytics" access="public" returntype="any" output="false">
	<cfargument name="method" type="string" required="true" />
	<cfargument name="args"   type="any"    default="" />

	<cfscript>
		var ev  = event ?: getRequestContext();
		var prc = prc   ?: ev.getPrivateCollection();

		if( arguments.method == "disable" ) {
			structDelete( prc, "_analytics" );
			return;
		}

		if ( !prc.keyExists( "_analytics" ) ) {
			return;
		}

		return prc._analytics[ arguments.method ]( argumentCollection=arguments.args );
	</cfscript>
</cffunction>
