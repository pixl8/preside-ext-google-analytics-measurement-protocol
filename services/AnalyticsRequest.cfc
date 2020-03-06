component accessors=true {

	property name="v"          type="string"  default="1";
	property name="tid"        type="string"  default="";
	property name="cid"        type="string"  default="";
	property name="uid"        type="string"  default="";
	property name="ds"         type="string"  default="web";
	property name="uip"        type="string"  default="#cgi.remote_addr     ?: ''#";
	property name="ua"         type="string"  default="#cgi.http_user_agent ?: ''#";
	property name="dr"         type="string"  default="#cgi.http_referer    ?: ''#";

	property name="cn"         type="string"  default="#url.utm_campaign    ?: ''#";
	property name="cs"         type="string"  default="#url.utm_source      ?: ''#";
	property name="cm"         type="string"  default="#url.utm_medium      ?: ''#";
	property name="ck"         type="string"  default="#url.utm_term        ?: ''#";
	property name="cc"         type="string"  default="#url.utm_content     ?: ''#";
	property name="ci"         type="string"  default="#url.utm_id          ?: ''#";
	property name="gclid"      type="string"  default="#url.gclid           ?: ''#";
	property name="dclid"      type="string"  default="#url.dclid           ?: ''#";

	property name="debugMode"  type="boolean";

	property name="pageView"   type="struct";
	property name="events"     type="array";
	property name="dimensions" type="struct";
	property name="metrics"    type="struct";

	function init(
		  required string  propertyId
		, required string  clientId
		, required string  userId
		,          string  dataSource = "web"
		,          boolean debugMode  = false
	) {
		setTid( arguments.propertyId );
		setCid( arguments.clientId );
		if ( len( arguments.userId ) ) {
			setUid( arguments.userId );
		}
		setDs( arguments.dataSource );
		setDebugMode( arguments.debugMode );

		variables.pageView   = {};
		variables.events     = [];
		variables.dimensions = {};
		variables.metrics    = {};

		return this;
	}

	public AnalyticsRequest function setPageView( required string uri, string title ) {
		var eventData = {
			dl = arguments.uri
		};
		if ( arguments.keyExists( "title" ) ) {
			eventData.dt = arguments.title;
		}

		variables.pageView = eventData;

		return this;
	}

	public AnalyticsRequest function addEvent(
		  required string  category
		, required string  action
		,          string  label
		,          numeric value
	) {
		var eventData = {
			  ec = arguments.category
			, ea = arguments.action
		};
		if ( arguments.keyExists( "label" ) ) {
			eventData.el = arguments.label;
		}
		if ( arguments.keyExists( "value" ) ) {
			eventData.ev = arguments.value;
		}

		variables.events.append( eventData );

		return this;
	}

	public AnalyticsRequest function setDimension( required numeric index, required string value ) {
		variables.dimensions[ arguments.index ] = arguments.value;

		return this;
	}

	public AnalyticsRequest function setMetric( required numeric index, required string value ) {
		variables.metrics[ arguments.index ] = arguments.value;

		return this;
	}

	public string function baseParams( required array fields ) {
		var params = [];

		for( var field in arguments.fields ) {
			if ( len( variables[ field ] ) ) {
				params.append( "#field#=#urlEncodedFormat( variables[ field ] )#" );
			}
		}
		for( var index in variables.dimensions ) {
			params.append( "cd#index#=#urlEncodedFormat( variables.dimensions[ index ] )#" );
		}
		for( var index in variables.metrics ) {
			params.append( "cm#index#=#urlEncodedFormat( variables.metrics[ index ] )#" );
		}

		return params.toList( "&" );
	}

}