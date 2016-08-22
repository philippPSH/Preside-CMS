component extends="resources.HelperObjects.PresideBddTestCase" {

	function run() {
		describe( "getCondition()", function(){
			it( "should return a deSerialized expression from database lookup of serialized expression by ID", function(){
				var service     = _getService();
				var conditionId = CreateUUId();
				var expressions = [{
					  expression = "test.expression"
					, fields     = { test=CreateUUId(), _is=true }
				}];
				var dbRecord    = QueryNew( "id,condition_name,context,expressions", "varchar,varchar,varchar,varchar", [[
					conditionId, "My Condition", "visitor", SerializeJson( expressions )
				]] );


				mockConditionDao.$( "selectData" ).$args( id=conditionId ).$results( dbRecord );

				expect( service.getCondition( conditionId ) ).toBe( {
					  id          = conditionId
					, name        = dbRecord.condition_name
					, context     = dbRecord.context
					, expressions = expressions
				} );

			} );

			it( "should return an empty struct when the condition does not exist", function(){
				var service     = _getService();
				var conditionId = CreateUUId();
				var dbRecord    = QueryNew( "id,condition_name,context,expressions" );

				mockConditionDao.$( "selectData" ).$args( id=conditionId ).$results( dbRecord );

				expect( service.getCondition( conditionId ) ).toBe( {} );
			} );
		} );

		describe( "validateCondition()", function(){
			it( "should return false when passed condition is not valid JSON", function(){
				var service          = _getService();
				var validationResult = _newValidationResult();

				expect( service.validateCondition(
					  condition        = "{lsakjdfljd.test"
					, validationResult = validationResult
					, context          = "any"
				) ).toBeFalse();
			} );

			it( "should add a general validation result error explaining invalid JSON packet error when condition is invalid json", function(){
				var service          = _getService();
				var validationResult = _newValidationResult();

				service.validateCondition(
					  condition        = "{lsakjdfljd.test"
					, validationResult = validationResult
					, context          = "any"
				);

				expect( validationResult.getGeneralMessage() ).toBe( "The passed condition was malformed and could not be read" );
			} );

			it( "should return false when passed JSON condition does not evaluate to an array", function(){
				var service          = _getService();
				var validationResult = _newValidationResult();

				expect( service.validateCondition(
					  condition        = "{ ""test"":true }"
					, validationResult = validationResult
					, context          = "any"
				) ).toBeFalse();
			} );

			it( "should add a general validation result error explaining condition is malformed when passed JSON condition does not evaluate to an array", function(){
				var service          = _getService();
				var validationResult = _newValidationResult();

				service.validateCondition(
					  condition        = "{ ""test"":true }"
					, validationResult = validationResult
					, context          = "any"
				);

				expect( validationResult.getGeneralMessage() ).toBe( "The passed condition was malformed and could not be read" );
			} );

			it( "should return false when an item in an odd row is a simple value", function(){
				var service              = _getService();
				var validationResult     = _newValidationResult();
				var badlyFormedCondition = SerializeJson( [
					{ "expression":"event.attendance", "fields":{} },
					"or",
					"blah",
					[
						{ "expression":"has.membership", "fields":{} },
						"and",
						{ "expression":"user.visits", "fields":{} },
						"and",
						[
							{ "expression":"user.spend", "fields":{} },
							"or",
							{ "expression":"found.egg", "fields":{} }
						]
					],
					"and",
					"or", // expect either an expression or expression group here
					{ "expression":"is.legend", "fields":{} }
				] );

				expect( service.validateCondition(
					  condition        = badlyFormedCondition
					, validationResult = validationResult
					, context          = "any"
				) ).toBeFalse();
			} );

			it( "should add a general validation result error explaining condition is malformed when an item in an odd row is a simple value", function(){
				var service          = _getService();
				var validationResult = _newValidationResult();
				var badlyFormedCondition = SerializeJson( [
					{ "expression":"event.attendance", "fields":{} },
					"or",
					"blah",
					[
						{ "expression":"has.membership", "fields":{} },
						"and",
						{ "expression":"user.visits", "fields":{} },
						"and",
						[
							{ "expression":"user.spend", "fields":{} },
							"or",
							{ "expression":"found.egg", "fields":{} }
						]
					],
					"and",
					"or", // expect either an expression or expression group here
					{ "expression":"is.legend", "fields":{} }
				] );

				service.validateCondition(
					  condition        = badlyFormedCondition
					, validationResult = validationResult
					, context          = "any"
				);

				expect( validationResult.getGeneralMessage() ).toBe( "The passed condition was malformed and could not be read" );
			} );

			it( "should return false when passed condition has a simple value in an even row that is neither 'and' or 'or'", function(){
				var service              = _getService();
				var validationResult     = _newValidationResult();
				var badlyFormedCondition = SerializeJson( [
					{ "expression":"event.attendance", "fields":{} },
					"or",
					[
						{ "expression":"has.membership", "fields":{} },
						"and",
						{ "expression":"user.visits", "fields":{} },
						"and",
						[
							{ "expression":"user.spend", "fields":{} },
							"fubar",
							{ "expression":"found.egg", "fields":{} }
						]
					],
					"and",
					{ "expression":"is.legend", "fields":{} }
				] );

				expect( service.validateCondition(
					  condition        = badlyFormedCondition
					, validationResult = validationResult
					, context          = "any"
				) ).toBeFalse();
			} );

			it( "should add a general validation result error explaining condition is malformed when passed condition has a simple value in an even row that is neither 'and' or 'or'", function(){
				var service          = _getService();
				var validationResult = _newValidationResult();
				var badlyFormedCondition = SerializeJson( [
					{ "expression":"event.attendance", "fields":{} },
					"or",
					[
						{ "expression":"has.membership", "fields":{} },
						"and",
						{ "expression":"user.visits", "fields":{} },
						"and",
						[
							{ "expression":"user.spend", "fields":{} },
							"fubar",
							{ "expression":"found.egg", "fields":{} }
						]
					],
					"and",
					{ "expression":"is.legend", "fields":{} }
				] );

				service.validateCondition(
					  condition        = badlyFormedCondition
					, validationResult = validationResult
					, context          = "any"
				);

				expect( validationResult.getGeneralMessage() ).toBe( "The passed condition was malformed and could not be read" );
			} );

			it( "should return false when passed condition has an item in an even row that is not a simple value", function(){
				var service              = _getService();
				var validationResult     = _newValidationResult();
				var badlyFormedCondition = SerializeJson( [
					{ "expression":"event.attendance", "fields":{} },
					"or",
					[
						{ "expression":"has.membership", "fields":{} },
						"and",
						{ "expression":"user.visits", "fields":{} },
						"and",
						[
							{ "expression":"user.spend", "fields":{} },
							{ "test" : true },
							{ "expression":"found.egg", "fields":{} }
						]
					],
					"and",
					{ "expression":"is.legend", "fields":{} }
				] );

				expect( service.validateCondition(
					  condition        = badlyFormedCondition
					, validationResult = validationResult
					, context          = "any"
				) ).toBeFalse();
			} );

			it( "should add a general validation result error explaining condition is malformed when passed condition has an item in an even row that is not a simple value", function(){
				var service          = _getService();
				var validationResult = _newValidationResult();
				var badlyFormedCondition = SerializeJson( [
					{ "expression":"event.attendance", "fields":{} },
					"or",
					[
						{ "expression":"has.membership", "fields":{} },
						"and",
						{ "expression":"user.visits", "fields":{} },
						"and",
						[
							{ "expression":"user.spend", "fields":{} },
							{ "test" : true },
							{ "expression":"found.egg", "fields":{} }
						]
					],
					"and",
					{ "expression":"is.legend", "fields":{} }
				] );

				service.validateCondition(
					  condition        = badlyFormedCondition
					, validationResult = validationResult
					, context          = "any"
				);

				expect( validationResult.getGeneralMessage() ).toBe( "The passed condition was malformed and could not be read" );
			} );


			it( "should return false when passed condition has an item in an odd row that is a struct but does not have 'expression' and 'fields' keys", function(){
				var service              = _getService();
				var validationResult     = _newValidationResult();
				var badlyFormedCondition = SerializeJson( [
					{ "expression":"event.attendance", "fields":{} },
					"or",
					[
						{ "expression":"has.membership", "fields":{} },
						"and",
						{ "expression":"user.visits", "fields":{} },
						"and",
						[
							{ "test":true },
							"and",
							{ "expression":"found.egg", "fields":{} }
						]
					],
					"and",
					{ "expression":"is.legend", "fields":{} }
				] );

				expect( service.validateCondition(
					  condition        = badlyFormedCondition
					, validationResult = validationResult
					, context          = "any"
				) ).toBeFalse();
			} );

			it( "should add a general validation result error explaining condition is malformed when passed condition has an item in an odd row that is a struct but does not have 'expression' and 'fields' keys", function(){
				var service          = _getService();
				var validationResult = _newValidationResult();
				var badlyFormedCondition = SerializeJson( [
					{ "expression":"event.attendance", "fields":{} },
					"or",
					[
						{ "expression":"has.membership", "fields":{} },
						"and",
						{ "expression":"user.visits", "fields":{} },
						"and",
						[
							{ "test":true },
							"and",
							{ "expression":"found.egg", "fields":{} }
						]
					],
					"and",
					{ "expression":"is.legend", "fields":{} }
				] );

				service.validateCondition(
					  condition        = badlyFormedCondition
					, validationResult = validationResult
					, context          = "any"
				);

				expect( validationResult.getGeneralMessage() ).toBe( "The passed condition was malformed and could not be read" );
			} );

			it( "should return false when passed condition has an invalid expression item", function(){
				var service              = _getService();
				var validationResult     = _newValidationResult();
				var context              = CreateUUId();
				var badlyFormedCondition = [
					{ "expression":"event.attendance", "fields":{ test=CreateUUId() } }
				];

				mockExpressionService.$( "isExpressionValid" ).$args(
					  expressionId     = badlyFormedCondition[1].expression
					, fields           = badlyFormedCondition[1].fields
					, context          = context
					, validationResult = validationResult
				).$results( false );

				expect( service.validateCondition(
					  condition        = SerializeJson( badlyFormedCondition )
					, validationResult = validationResult
					, context          = context
				) ).toBeFalse();
			} );
		} );

		describe( "evaluateCondition()", function(){
			it( "should return true when it contains a single expression that evaluates to true for the given payload", function(){
				var service     = _getService();
				var payload     = { blah=CreateUUId() };
				var context     = CreateUUId();
				var conditionId = CreateUUId();
				var condition   = [{
					  expression = "test.expression"
					, fields     = { test=CreateUUId(), _is=true }
				}];

				service.$( "getCondition" ).$args( conditionId ).$results( { expressions=condition } );

				mockExpressionService.$( "evaluateExpression" ).$args(
					  expressionId     = condition[1].expression
					, configuredFields = condition[1].fields
					, context          = context
					, payload          = payload
				).$results( true );

				expect( service.evaluateCondition(
					  conditionId = conditionId
					, context     = context
					, payload     = payload
				) ).toBeTrue();
			} );

			it( "should return false when it contains a single expression that evaluates to false for the given payload", function(){
				var service     = _getService();
				var payload     = { blah=CreateUUId() };
				var context     = CreateUUId();
				var conditionId = CreateUUId();
				var condition   = [{
					  expression = "test.expression"
					, fields     = { test=CreateUUId(), _is=true }
				}];

				service.$( "getCondition" ).$args( conditionId ).$results( { expressions=condition } );

				mockExpressionService.$( "evaluateExpression" ).$args(
					  expressionId     = condition[1].expression
					, configuredFields = condition[1].fields
					, context          = context
					, payload          = payload
				).$results( false );

				expect( service.evaluateCondition(
					  conditionId = conditionId
					, context     = context
					, payload     = payload
				) ).toBeFalse();
			} );

			it( "should return false when the condition does not exist", function(){
				var service     = _getService();
				var payload     = { blah=CreateUUId() };
				var context     = CreateUUId();
				var conditionId = CreateUUId();

				service.$( "getCondition" ).$args( conditionId ).$results( {} );

				expect( service.evaluateCondition(
					  conditionId = conditionId
					, context     = context
					, payload     = payload
				) ).toBeFalse();
			} );
		} );
	}

// PRIVATE HELPERS
	private any function _getService() {
		variables.mockColdbox = createStub();
		variables.mockExpressionService = createEmptyMock( "preside.system.services.rulesEngine.RulesEngineExpressionService" );
		variables.mockConditionDao = createStub();

		var service = createMock( object=new preside.system.services.rulesEngine.RulesEngineConditionService(
			expressionService = mockExpressionService
		) );

		service.$( "$getColdbox", mockColdbox );
		service.$( "$getPresideObject" ).$args( "rules_engine_condition" ).$results( mockConditionDao );
		mockExpressionService.$( "isExpressionValid", true );

		return service;
	}

	private any function _newValidationResult() {
		return new preside.system.services.validation.ValidationResult();
	}
}