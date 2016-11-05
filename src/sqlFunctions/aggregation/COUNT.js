const AggregationFunction = require('../../AggregationFunction');

class SUM extends AggregationFunction
{
	constructor()
	{
		super();

		this.count = 0;
	}

	init()
	{
	}

	update(args)
	{
		if (!args.length) {
			this.count++;
			return;
		}

		if (args[0] === undefined || args[0] === null) {
			return;
		}

		this.count++;
	}

	result()
	{
		return this.count;
	}

	deinit()
	{
		this.count = 0;
	}
}

module.exports = SUM;