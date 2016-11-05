const BasicFunction = require('../../BasicFunction');

class DATE extends BasicFunction
{
	call(args)
	{
		let now = new Date;

		if (args.length) {
			now = new Date(args[0]);
		}

		return now.getUTCFullYear() +
			'-' + (100 + now.getUTCMonth() + 1).toString().substr(1) +
			'-' + (100 + now.getUTCDate()).toString().substr(1)
		;
	}
}

module.exports = DATE;