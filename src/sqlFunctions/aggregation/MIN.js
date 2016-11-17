'use strict';

const AggregationFunction = require('../../AggregationFunction');
const DataType = require('../../DataType');

class MIN extends AggregationFunction
{
	constructor()
	{
		super();

		this.min = null;
	}

	static dataType()
	{
		return DataType.MIXED;
	}

	init()
	{
	}

	update(args)
	{
		if (args[0] === undefined || args[0] === null) {
			return;
		}

		if (this.min === null) {
			this.min = args[0]
		} else {
			this.min = args[0] < this.min ? args[0] : this.min;
		}
	}

	result()
	{
		return this.min;
	}

	deinit()
	{
		this.min = null;
	}
}

module.exports = MIN;
