component extends="coldbox.system.Interceptor" {

	property name="analyticsService" inject="delayedInjector:analyticsService";

	public void function configure() {}

	public void function postPresideRequestCapture( event ) {
		var ev     = rc.event ?: "";
		var ignore = [
			  "^admin\."
			, "^core\.AssetDownload\."
		];

		if ( !len( ev ) ) {
			return;
		}

		for( var pattern in ignore ) {
			if ( reFindNoCase( pattern, ev ) ) {
				return;
			}
		}

		prc._analytics = prc._analytics ?: analyticsService.newRequest();
	}

	public void function postRender( event ) {
		if ( !prc.keyExists( "_analytics" ) ) {
			return;
		}

		if ( prc._analytics.getPageView().isEmpty() ) {
			prc._analytics.setPageView( event.getBaseUrl() & event.getCurrentUrl(), prc.presidePage.title ?: "" );
		}

		analyticsService.postPayloads( prc._analytics );
	}

}