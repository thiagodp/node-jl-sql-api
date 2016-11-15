const SqlNodes = require('./sql/Nodes');
const BasicExpression = require('./BasicExpression');
const AggregationFunction = require('./AggregationFunction');
const AggregationCall = require('./AggregationCall');
const SqlLogicError = require('./error/SqlLogicError');

class AggregationExpression extends BasicExpression
{
	constructor(preparingContext, expression)
	{
		super(preparingContext, expression);

		this.aggregationCalls = this.createAggregationCalls();

		this.result = () => preparingContext.sqlToJs.nodeToFunction(expression)({});
	}

	createAggregationCalls()
	{
		const calls = [];
		const sqlToJs = this.preparingContext.sqlToJs;

		const nodes = this.expression.childNodesRecursive().concat([this.expression]);

		for (let node of nodes) {
			if (!(node instanceof SqlNodes.Call)) {
				continue;
			}

			const func = this.preparingContext.functionsMap.need(node.function.fragments);
			if (!(func.prototype instanceof AggregationFunction)) {
				continue;
			}

			for (let arg of node.args) {
				if (this.preparingContext.isAggregationExpression(arg)) {
					throw new SqlLogicError('Nested aggregation function is not alowed');
				}
			}

			calls.push(new AggregationCall(sqlToJs, node, func));
		}

		return calls;
	}

	valueSource()
	{
		throw new SqlLogicError('Not allowed for aggregation columns');
	}
}

module.exports = AggregationExpression;