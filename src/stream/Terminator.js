const Writable = require('stream').Writable;

class Terminator extends Writable
{
	constructor()
	{
		super({
			objectMode: true
		});
	}

	_write(chunk, charset, cb)
	{
		cb();
	}
}

module.exports = Terminator;
