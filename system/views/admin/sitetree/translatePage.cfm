<cfscript>
	formId                 = "translate-page-form";
	pageId                 = rc.id ?: "";
	currentLanguageId      = rc.language ?: "";
	version                = rc.version ?: "";
	translations           = prc.translations ?: [];
	translateUrlBase       = event.buildAdminLink( linkTo="sitetree.translatePage", queryString="id=#pageId#&language=" );
	pageTypeObjectName     = prc.pageTypeObjectName     ?: "page";
	pageIsMultilingual     = prc.pageIsMultilingual     ?: false;
	pageTypeIsMultilingual = prc.pageTypeIsMultilingual ?: false;
</cfscript>

<cfoutput>
	<cfif translations.len() gt 1>
		<div class="top-right-button-group">
			<button data-toggle="dropdown" class="btn btn-sm btn-info pull-right inline">
				<span class="fa fa-caret-down"></span>
				<i class="fa fa-fw fa-globe"></i>&nbsp; #translateResource( uri="cms:datamanager.translate.record.btn" )#
			</button>

			<ul class="dropdown-menu pull-right" role="menu" aria-labelledby="dLabel">
				<cfloop array="#translations#" index="i" item="language">
					<cfif language.id != currentLanguageId>
						<li>
							<a href="#translateUrlBase##language.id#">
								<i class="fa fa-fw fa-pencil"></i>&nbsp; #language.name# (#translateResource( 'cms:multilingal.status.#language.status#' )#)
							</a>
						</li>
					</cfif>
				</cfloop>
			</ul>
		</cfif>
	</div>

	#renderViewlet( event='admin.datamanager.translationVersionNavigator', args={
		  object         = pageIsMultilingual ? "page" : pageTypeObjectName
		, id             = pageId
		, version        = version
		, language       = currentLanguageId
		, baseUrl        = event.buildAdminLink( linkTo="sitetree.translatePage", queryString="id=#pageId#&language=#currentLanguageId#&version=" )
		, allVersionsUrl = event.buildAdminLink( linkTo="sitetree.translationHistory", queryString="id=#pageId#&language=#currentLanguageId#" )
	} )#

	<form id="#formId#" data-auto-focus-form="true" data-dirty-form="protect" class="form-horizontal translate-page-form" method="post" action="#event.buildAdminLink( linkTo='sitetree.translatePageAction' )#">
		<input type="hidden" name="id"       value="#pageId#" />
		<input type="hidden" name="language" value="#currentLanguageId#" />

		#renderForm(
			  formName          = prc.mainFormName ?: ""
			, mergeWithFormName = prc.mergeFormName ?: ""
			, context           = "admin"
			, formId            = formId
			, savedData         = prc.savedTranslation ?: {}
			, validationResult  = rc.validationResult ?: ""
		)#

		<div class="form-actions row">
			<div class="col-md-offset-2">
				<a href="#event.buildAdminLink( linkTo='sitetree.editPage', queryString='id=#pageId#' )#" class="btn btn-default" data-global-key="c">
					<i class="fa fa-reply bigger-110"></i>
					#translateResource( "cms:sitetree.cancel.btn" )#
				</a>

				<button class="btn btn-info" type="submit" tabindex="#getNextTabIndex()#">

					<i class="fa fa-check bigger-110"></i>
					#translateResource( "cms:sitetree.savepage.btn" )#
				</button>
			</div>
		</div>
	</form>
</cfoutput>