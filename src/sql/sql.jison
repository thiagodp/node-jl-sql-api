%{
const Nodes = require('./Nodes.js');
const JL_JISON_INPUT_SYMBOL = Symbol('JL_JISON_INPUT_SYMBOL');
%}

/* lexical grammar */
%lex

%{
if (!(JL_JISON_INPUT_SYMBOL in yy.lexer)) {
	yy.lexer[JL_JISON_INPUT_SYMBOL] = this.matches.input;
}
%}

%options case-insensitive ranges backtrack_lexer

%%
\s+	{}

"SELECT"	{ return 'SELECT'; }
"DELETE"	{ return 'DELETE'; }
"INSERT"	{ return 'INSERT'; }

","	{ return ','; }
"NULL"	{ return 'NULL'; }
"TRUE"	{ return 'TRUE'; }
"FALSE"	{ return 'FALSE'; }

"FROM"	{ return 'FROM'; }
"DISTINCT"	{ return 'DISTINCT'; }
"NUMERIC"	{ return 'NUMERIC'; }
"WHERE"	{ return 'WHERE'; }
"ORDER"	{ return 'ORDER'; }
"GROUP"	{ return 'GROUP'; }
"BY"	{ return 'BY'; }
"HAVING"	{ return 'HAVING'; }
"COUNT"	{ return 'COUNT'; }
"LIMIT"	{ return 'LIMIT'; }
"OFFSET"	{ return 'OFFSET'; }
"LEFT"	{ return 'LEFT'; }
"INNER"	{ return 'INNER'; }

"INTERVAL"	{ return 'INTERVAL'; }
"YEAR" { return 'YEAR'; }
"MONTH" { return 'MONTH'; }
"DAY" { return 'DAY'; }
"HOUR" { return 'HOUR'; }
"MINUTE" { return 'MINUTE'; }
"SECOND" { return 'SECOND'; }

\"(\\.|[^\\"])*\"	{ return 'STRING'; }
\'(\\.|[^\\'])*\'	{ return 'STRING'; }
[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)? { return 'NUMBER'; }
\:[a-z_][a-z0-9_]*	{ return 'BINDING_VALUE_SCALAR'; }
\:\:[a-z_][a-z0-9_]*	{ return 'BINDING_VALUE_LIST'; }
\[\:[a-z_][a-z0-9_]*\]	{ return 'BINDING_IDENT'; }
\[\:\:[a-z_][a-z0-9_]*\]	{ return 'BINDING_IDENT_LIST'; }
"AS"	{ return 'AS'; }
"ASC"	{ return 'ASC'; }
"DESC"	{ return 'DESC'; }
"STRICT" { return 'STRICT'; }
"IN"	{ return 'IN'; }
"ON"	{ return 'ON'; }
"JOIN"	{ return 'JOIN'; }
"+"	{ return '+'; }
"-"	{ return '-'; }
"/"	{ return '/'; }
"*"	{ return '*'; }
"%"	{ return '%'; }
"==="	{ return '==='; }
"!=="	{ return '!=='; }
"=="	{ return '='; }
"="	{ return '='; }
"("	{ return '('; }
")"	{ return ')'; }
"<="	{ return '<='; }
">="	{ return '>='; }
"<"	{ return '<'; }
">"	{ return '>'; }
"AND"	{ return 'AND'; }
"&&"	{ return 'AND'; }
"OR"	{ return 'OR'; }
"||"	{ return 'OR'; }
"."	{ return '.'; }
"!="	{ return '!='; }
"!"	{ return '!'; }

"{" { return '{'; }
"}" { return '}'; }
":" { return ':'; }
"[" { return '['; }
"]" { return ']'; }

(\@([a-z_][a-z0-9_]*|))	{ return 'DATA_SOURCE_IDENT'; }
\`(\\.|[^\\`])*\`		{ return 'IDENT'; }
([a-z_][a-z0-9_]*)		{ return 'IDENT'; }

<<EOF>>	{ return 'EOF'; }

/lex

/* operator associations and precedence */

%left ','
%left 'AS'
%left 'AND' 'OR'

%left '.' '!'
%left '>' '<' '>=' '<='

%left '=' '==' '!=' '===' '!=='
%left '+' '-'
%left '*' '/' '%'
%left 'COUNT'
%left 'FROM' 'AS' 'DISTINCT' 'STRICT' 'IN' 'WHERE' 'HAVING' 'LIMIT' 'OFFSET'
%left 'ORDER' 'GROUP' 'BY' 'ASC' 'DESC'
%left 'JOIN' 'INNER' 'LEFT'

%start expressions

%% /* language grammar */

expressions
	: select EOF { return $1; }
	| delete EOF { return $1; }
	| insert EOF { return $1; }
;

keywords
	: SELECT { $$ = $1 }
	| FROM { $$ = $1 }
	| AS { $$ = $1 }
	| STRICT { $$ = $1 }
	| IN { $$ = $1 }
	| AND { $$ = $1 }
	| OR { $$ = $1 }
	| WHERE { $$ = $1 }
	| ORDER { $$ = $1 }
	| GROUP { $$ = $1 }
	| BY { $$ = $1 }
	| HAVING { $$ = $1 }
	| LIMIT { $$ = $1 }
	| OFFSET { $$ = $1 }
	| ASC { $$ = $1 }
	| DESC { $$ = $1 }
	| JOIN { $$ = $1 }
	| LEFT { $$ = $1 }
	| INNER { $$ = $1 }
;

dataSourceIdent
	: 'DATA_SOURCE_IDENT' { $$ = new Nodes.DataSourceIdent($1) }
;

ident
	: 'IDENT' { $$ = new Nodes.Ident($1); }
	| 'BINDING_IDENT' { $$ = new Nodes.BindingIdent($1); }
	| keywords { $$ = new Nodes.Ident($1); }
;

complexIdent
	: complexIdent '.' ident { $1.addFragment($3); $$ = $1; }
	| complexIdent '.' 'BINDING_IDENT_LIST' { $1.addFragment(new Nodes.BindingIdentList($3)); $$ = $1; }
	| 'BINDING_IDENT_LIST' { $$ = new Nodes.ComplexIdent(['@', new Nodes.BindingIdentList($1)]); }
	| ident { $$ = new Nodes.ComplexIdent(['@', $1]); }
	| dataSourceIdent { $$ = new Nodes.ComplexIdent([$1.name]); }
;

number: 'NUMBER' { $$ = new Nodes.Number($1); };

intervalUnit
	: 'YEAR' { $$ = Nodes.Interval.UNIT_YEAR; }
	| 'MONTH' { $$ = Nodes.Interval.UNIT_MONTH; }
	| 'DAY' { $$ = Nodes.Interval.UNIT_DAY; }
	| 'HOUR' { $$ = Nodes.Interval.UNIT_HOUR; }
	| 'MINUTE' { $$ = Nodes.Interval.UNIT_MINUTE; }
	| 'SECOND' { $$ = Nodes.Interval.UNIT_SECOND; }
;

interval
	: 'INTERVAL' expression intervalUnit { $$ = new Nodes.Interval(); $$.add($2, $3); }
	| interval expression intervalUnit { $$.add($2, $3); }
;

jsonObjectItem
	: 'STRING' ':' const { $$ = {key: (new Nodes.String($1)).value, value: $3.value}; }
;

jsonObjectItems
	: jsonObjectItem { $$ = {}; $$[$1.key] = $1.value; }
	| jsonObjectItems ',' jsonObjectItem { $$ = $1; $$[$3.key] = $3.value; }
;

jsonArrayItem
	: const { $$ = $1.value; }
;

jsonArrayItems
	: jsonArrayItem { $$ = [$1]; }
	| jsonArrayItems ',' jsonArrayItem { $$ = $1; $$.push($3); }
;

jsonValue
	: '{' '}' { $$ = new Nodes.JsonValue({}); }
	| '{' jsonObjectItems '}' { $$ = new Nodes.JsonValue($2); }
	| '[' ']' { $$ = new Nodes.JsonValue([]); }
	| '[' jsonArrayItems ']' { $$ = new Nodes.JsonValue($2); }
;

scalarConst
	: 'STRING' { $$ = new Nodes.String($1); }
	| number   { $$ = $1; }
	| 'NULL'   { $$ = new Nodes.Null(); }
	| 'TRUE'   { $$ = new Nodes.Boolean(true); }
	| 'FALSE'   { $$ = new Nodes.Boolean(false); }
;

const
	: scalarConst { $$ = $1; }
	| jsonValue { $$ = $1; }
;

expression
	: DISTINCT expression       { $$ = new Nodes.Distinct($2); }
	| expression '*' expression { $$ = new Nodes.BinaryArithmeticOperation($2, $1, $3); }
	| expression '%' expression { $$ = new Nodes.BinaryArithmeticOperation($2, $1, $3); }
	| expression '/' expression { $$ = new Nodes.BinaryArithmeticOperation($2, $1, $3); }
	| expression '+' expression { $$ = new Nodes.BinaryArithmeticOperation($2, $1, $3); }
	| expression '-' expression { $$ = new Nodes.BinaryArithmeticOperation($2, $1, $3); }
	| expression '+' interval { $$ = new Nodes.BinaryArithmeticOperation($2, $1, $3); }
	| expression '-' interval { $$ = new Nodes.BinaryArithmeticOperation($2, $1, $3); }
	| expression '=' expression { $$ = new Nodes.ComparsionOperation($2, $1, $3); }
	| expression '!==' expression { $$ = new Nodes.ComparsionOperation($2, $1, $3); }
	| expression '===' expression { $$ = new Nodes.ComparsionOperation($2, $1, $3); }
	| expression '!=' expression { $$ = new Nodes.ComparsionOperation($2, $1, $3); }
	| expression 'AND' expression { $$ = new Nodes.LogicalOperation($2, $1, $3); }
	| expression 'OR' expression { $$ = new Nodes.LogicalOperation($2, $1, $3); }
	| expression '>' expression { $$ = new Nodes.ComparsionOperation($2, $1, $3); }
	| expression '>=' expression { $$ = new Nodes.ComparsionOperation($2, $1, $3); }
	| expression '<' expression { $$ = new Nodes.ComparsionOperation($2, $1, $3); }
	| expression '<=' expression { $$ = new Nodes.ComparsionOperation($2, $1, $3); }
	| '-' expression { $$ = new Nodes.UnaryArithmeticOperation($1, $2); }
	| '!' expression { $$ = new Nodes.UnaryLogicalOperation($1, $2); }
	| expression 'STRICT' 'IN' '(' expressionsList ')' { $$ = new Nodes.StrictIn($1, $5); }
	| expression 'IN' '(' expressionsList ')' { $$ = new Nodes.UnstrictIn($1, $4); }
	| complexIdent '(' expressionsList ')' { $$ = new Nodes.Call(new Nodes.FunctionIdent($1), $3); }
	| complexIdent '(' ')' { $$ = new Nodes.Call(new Nodes.FunctionIdent($1)); }
	| 'COUNT' '(' expression ')' { $$ = new Nodes.Call(new Nodes.FunctionIdent(new Nodes.ComplexIdent['@', $1]), new Nodes.ExpressionsList([$3])); }
	| 'COUNT' '(' '*' ')' { $$ = new Nodes.Call(new Nodes.FunctionIdent(new Nodes.ComplexIdent(['@', $1]))); }
	| 'COUNT' { $$ = new Nodes.ColumnIdent(['@', $1]) }
	| complexIdent { $$ = Nodes.ColumnIdent.fromComplexIdent($1) }
	| const { $$ = $1; }
	| 'BINDING_VALUE_SCALAR' { $$ = new Nodes.BindingValueScalar($1); }
	| '(' expression ')' { $$ = new Nodes.Brackets($2); }
;

expressionsList
	: expressionsList ',' expression { $1.push($3); $$ = $1; }
	| expressionsList ',' 'BINDING_VALUE_LIST' { $1.push(new Nodes.BindingValueList($3)); $$ = $1; }
	| 'BINDING_VALUE_LIST' { $$ = new Nodes.ExpressionsList([new Nodes.BindingValueList($1)]); }
	| expression { $$ = new Nodes.ExpressionsList([$1]); }
;

column
	: expression 'AS' complexIdent { $$ = new Nodes.Column($1, $3); }
	| expression 'AS' 'COUNT' { $$ = new Nodes.Column($1, new Nodes.ColumnIdent(['@', $3])); }
	| expression            { var sql = yy.lexer[JL_JISON_INPUT_SYMBOL].slice(@$.range[0], @$.range[1]); $$ = new Nodes.Column($1, null, sql);}
;

columns
	: columns ',' columns    { $$ = $1.concat($3); }
	| column                 { $$ = [$1]; }
;

selectClause: 'SELECT' { $$ = new Nodes.Select(); };
deleteClause: 'DELETE' { $$ = new Nodes.Delete(); };
insertClause: 'INSERT' { $$ = new Nodes.Insert(); };

selectColumns
	: selectClause columns { $1.columns = $2; $$ = $1; }
	| selectClause '*' ',' columns { $1.allColumns = true; $1.columns = $4; $$ = $1; }
	| selectClause '*' { $1.columns = []; $1.allColumns = true; $$ = $1; }
;

table
	: complexIdent AS dataSourceIdent { $$ = new Nodes.Table(new Nodes.TableLocation($1), new Nodes.TableAlias($3)); }
	| complexIdent { $$ = new Nodes.Table(new Nodes.TableLocation($1)); }
;

selectFrom
	: selectColumns 'FROM' table { $1.table = $3; $$ = $1; }
	| selectColumns { $1.table = null; $$ = $1; }
;

join
	: JOIN table 'ON' expression       { $$ = new Nodes.InnerJoin($2, $4); }
	| INNER JOIN table 'ON' expression { $$ = new Nodes.InnerJoin($3, $5); }
	| LEFT JOIN table 'ON' expression  { $$ = new Nodes.LeftJoin($3, $5); }
;

selectJoin
	: selectFrom join       { $$ = $1; $$.join($2); }
	| selectFrom            { $$ = $1; }
;

where: WHERE expression { $$ = $2; };

selectWhere
	: selectJoin where { $$ = $1; $$.where = $2; }
	| selectJoin { $$ = $1; }
;

deleteWhere
	: deleteClause where { $$ = $1; $$.where = $2; }
	| deleteClause { $$ = $1; }
;

insertValues
	: insertClause const { $$ = new Nodes.Insert([$2.value]); }
	| insertValues ',' const { $$ = $1; $$.push($3.value); }
;

groupping
	: expression { $$ = new Nodes.GroupBy($1); }
;

grouppingList
	: grouppingList ',' groupping { $1.push($3); $$ = $1; }
	| groupping { $$ = [$1]; }
;

selectGroup
	: selectWhere GROUP BY grouppingList { $1.groups = $4; $$ = $1; }
	| selectWhere { $$ = $1; }
;

selectHaving
	: selectGroup HAVING expression { $1.having = $3; $$ = $1; }
	| selectGroup { $$ = $1; }
;

order
	: expression ASC  { $$ = new Nodes.OrderBy($1, $2) }
	| expression DESC { $$ = new Nodes.OrderBy($1, $2) }
	| expression      { $$ = new Nodes.OrderBy($1) }
	| expression NUMERIC ASC  { $$ = new Nodes.OrderBy($1, $3, $2) }
	| expression NUMERIC DESC { $$ = new Nodes.OrderBy($1, $3, $2) }
	| expression NUMERIC      { $$ = new Nodes.OrderBy($1, 'ASC', $2) }
;

ordersList
	: ordersList ',' order { $1.push($3); $$ = $1; }
	| order                { $$ = [$1]; }
;

selectOrder
	: selectHaving ORDER BY ordersList { $1.orders = $4; $$ = $1; }
	| selectHaving { $$ = $1; }
;

selectLimit
	: selectOrder LIMIT number ',' number { $1.setLimit($5.value, $3.value); $$ = $1; }
	| selectOrder LIMIT number OFFSET number { $1.setLimit($3.value, $5.value); $$ = $1; }
	| selectOrder LIMIT number { $1.setLimit($3.value); $$ = $1; }
	| selectOrder { $$ = $1 }
;

select
	: selectLimit { $$ = $1; }
;

delete
	: deleteWhere { $$ = $1; }
;

insert
	: insertValues {$$ = $1; }
;
