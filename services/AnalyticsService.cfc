/**
 * @presideService
 * @singleton
 */
component {
// CONSTRUCTOR
	/**
	 * @websiteVisitorService.inject websiteVisitorService
	 * @analyticsSettings.inject     coldbox:setting:analytics
	 */
	public any function init( required any websiteVisitorService, required struct analyticsSettings ) {
		_setWebsiteVisitorService( arguments.websiteVisitorService );
		_setDebugMode( arguments.analyticsSettings.debugMode ?: false );

		return this;
	}

//PUBLIC METHODS
	public AnalyticsRequest function newRequest() {
		var site = $getRequestContext().getSite();

		return new AnalyticsRequest(
			  clientId   = _getWebsiteVisitorService().getVisitorId()
			, userId     = $getWebsiteLoggedInUserId()
			, propertyId = site.analytics_property
			, debug      = _getDebugMode()
		);
	}

	public void function postPayloads( required AnalyticsRequest analyticsRequest ) {
		if ( !len( arguments.analyticsRequest.getTid() ) ) {
			return;
		}
		var payloads = _buildPayloads( arguments.analyticsRequest );
		if ( !payloads.len() ) {
			return;
		}

		var baseUrl  = "https://www.google-analytics.com";
		var endpoint = payloads.len() == 1 ? "/collect" : "/batch";
		var payload  = payloads.toList( chr( 10 ) );

		if ( arguments.analyticsRequest.getDebug() ) {
			$systemOutput( "Analytics payload:" & chr( 10 ) & payload );
		}

		thread
			action  = "run"
			name    = createUuid()
			uri     = "#baseUrl##endpoint#"
			ua      = arguments.analyticsRequest.getUa()
			payload = payload
		{
			http
				method    = "POST"
				url       = attributes.uri
				useragent = attributes.ua
				timeout   = 5
			{
				httpparam type="body" value=attributes.payload;
			}
		}
	}


// PRIVATE METHODS
	private array function _buildPayloads( required AnalyticsRequest analyticsRequest ) {
		var payloads = [];

		payloads.append( _pageViewPayloads( arguments.analyticsRequest ), true );
		payloads.append( _eventPayloads(    arguments.analyticsRequest ), true );

		return payloads;
	}

	private array function _pageViewPayloads( required AnalyticsRequest analyticsRequest ) {
		var pageviews  = [];
		var baseParams = arguments.analyticsRequest.baseParams( [ "v", "tid", "cid", "uid", "ds", "uip", "dr", "cn", "cs", "cm", "ck", "cc", "ci", "gclid", "dclid" ] );

		for( var item in arguments.analyticsRequest.getPageviews() ) {
			pageviews.append( _buildPayload( "pageview", item, baseParams ) );
		}

		return pageviews;
	}

	private array function _eventPayloads( required AnalyticsRequest analyticsRequest ) {
		var events     = [];
		var baseParams = arguments.analyticsRequest.baseParams( [ "v", "tid", "cid", "uid", "ds", "uip" ] );

		for( var item in arguments.analyticsRequest.getEvents() ) {
			events.append( _buildPayload( "event", item, baseParams ) );
		}

		return events;
	}

	private string function _buildPayload( required string type, required struct item, required string baseParams ) {
		var params = [ arguments.baseParams ];
		params.append( "t=#arguments.type#" );

		for( var key in arguments.item ) {
			params.append( "#key#=#urlEncodedFormat( arguments.item[ key ] )#" );
		}

		return params.toList( "&" );
	}


 // GETTERS AND SETTERS
	private any function _getWebsiteVisitorService() {
		return _websiteVisitorService;
	}
	private void function _setWebsiteVisitorService( required any websiteVisitorService ) {
		_websiteVisitorService = arguments.websiteVisitorService;
	}

	private boolean function _getDebugMode() {
		return _debugMode;
	}
	private void function _setDebugMode( required boolean debugMode ) {
		_debugMode = arguments.debugMode;
	}

}