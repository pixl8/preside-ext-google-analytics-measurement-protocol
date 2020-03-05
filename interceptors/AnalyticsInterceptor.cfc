component extends="coldbox.system.Interceptor" {

	property name="analyticsService" inject="delayedInjector:analyticsService";

	public void function configure() {}

	public void function postInitializePresideSiteteePage( event ) {
		prc._analytics = prc._analytics ?: analyticsService.newRequest();
	}

	public void function postRenderSiteTreePage( event ) {
		if ( prc.keyExists( "_analytics" ) ) {
			prc._analytics.addPageView( event.getBaseUrl() & event.getCurrentUrl(), prc.presidePage.title ?: "" );
		}
	}

	public void function postProcess( event ) {
		if ( prc.keyExists( "_analytics" ) ) {
			analyticsService.postPayloads( prc._analytics );
		}
	}

}