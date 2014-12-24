#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import logging

__all__ = ['DynSql']

VAR = "$"
VL = "$$"
RAW = "?"
JUDGE_YES = "#"
JUDGE_NO = "#!"

class SqlSeg(object):

    """
    var type
    $var_name or $(var_name): a single sql variable placeholder
    $$var_name or $$(var_name): a var-list sql variable placeholder
    ?var_name or ?(var_name): raw string substitute,
    we don't use % since this is the modulo operator in mysql
    #var or #(var): show sqls where it is in, but var must be exist
    #!var or #!(var): show sqls where it is in, but var must be not exist.
    """


    vars = re.compile(r"(\$|\${2}|\?|\#|\#\!)(\()?(\w+)((?(2)\)))").sub

    def __init__(self, s):
        # self.dyn: whether the sql segment is dynamic
        self.dyn = s.find(VL) >= 0 or s.find(RAW) >= 0
        self.vl_names = set()               # for $$
        self.raw_names = set()              # for ?
        self.var_names = []                 # all var name (ordered)
        self.var_judge_yes = []             # for #
        self.var_judge_no = []              # for #!
        self.tmpl = self.vars(self._repl, s)

    def __repr__(self):
        return self.tmpl

    def _repl(self, m):
        var_type, b, var_name, e = m.groups()
        self.var_names.append(var_name)
        # static
        if var_type == VAR:
            return self.dyn and "%%s" or "%s"
        elif var_type == JUDGE_YES:
            self.var_judge_yes.append(var_name)
            return ""
        elif var_type == JUDGE_NO:
            self.var_judge_no.append(var_name)
            return ""

        # dynamic
        if var_type == VL:
            self.vl_names.add(var_name)
        else:
            self.raw_names.add(var_name)

        return "%(" + var_name + ")s"

    def __call__(self, cntx):
        """
        @param cntx: a dict that contains key-val pairs to be substituted in
            the template.
        @return: (sql, param)
        """

        try:
            params, dyn_dict = [], {}
            for n in self.var_names:
                if n in self.raw_names:
                    dyn_dict[n] = str(cntx[n])
                    continue
                elif n in self.vl_names:
                    dyn_dict[n] = _vl_place_holders(len(cntx[n]))
                    params.extend(cntx[n])
                    continue
                elif n in self.var_judge_yes:
                    cntx[n]
                    continue
                elif n in self.var_judge_no:
                    try:
                        cntx[n]
                    except KeyError:
                        continue
                    return '', []
                params.append(cntx[n])
            return self.dyn and self.tmpl % dyn_dict or self.tmpl, params
        except (KeyError, AssertionError):
            return '', []


def _vl_place_holders(l):
    assert l > 0        # zero-length var list
    return "(%s)" % ", ".join(["%s"]*l)

class OptList(list):
    """ Optional list """

class OrList(list):
    """ Or list """

class DynSql(object):
    """
    Example: see __main__
    Do not use const variables in template !! They are not escaped.
    Pass const in constructor instead.
    """

    delimiter = re.compile(r"{|}|\[|\]|(\|{2})").finditer

    def __init__(self, tmpl, **const):
        self._tmpl = tmpl
        self._const = const

    def build(self):
        """
        Build a deep list to store the sql segments
        """
        tmpl, pos, deep_list = self._tmpl, 0, OrList([OptList()])
        stack = [deep_list, deep_list[-1]]
        for x in self.delimiter(tmpl):
            top = stack[-1]
            s = tmpl[pos: x.start()].strip()
            pos = x.end()
            if s:   # make a SqlSeg
                top.append(SqlSeg(s))
            d = x.group(0)
            if d == "}":
                stack.pop()
            elif d == "{":
                top.append(OptList())
                stack.append(top[-1])
            elif d == "[":
                top.append(OrList([OptList(),]))
                stack.append(top[-1])
                stack.append(top[-1][-1])
            elif d == "]":
                stack.pop()
                stack.pop()
            else:               # ||
                stack.pop()
                top = stack[-1]
                assert type(top) is OrList      # || not in []
                top.append(OptList())
                stack.append(top[-1])
        # handle the rest
        assert len(stack) == 2         # delimiter not proper close
        s = tmpl[pos:].strip()
        if s:
            stack[-1].append(SqlSeg(s))
        self._deep_list = deep_list

    def traverse(self, curr, cntx):
        """ Traverse over a list """
        if type(curr) is OrList:
            return self._t_orlist(curr, cntx)
        return self._t_optlist(curr, cntx)

    def _t_optlist(self, curr, cntx):
        segs, params = [], []
        for item in curr:
            t = type(item)
            # recursive
            if t is SqlSeg:
                seg, param = item(cntx)
            else:
                seg, param = self.traverse(item, cntx)
            seg = seg.strip()
            # treat the result
            if not seg and t is not OptList:        # return '' unless item is optional if seg is ''
                return '', []
            segs.append(seg)
            params.extend(param)
        return ' '.join(segs), params

    def _t_orlist(self, curr, cntx):
        for item in curr:
            seg, param = self._t_optlist(item, cntx)
            seg = seg.strip()
            if seg:     # return when one of the item is not ''
                return seg, param
        return '', []

    def __call__(self, cntx, raise_when_empty=True, pop_None=True):
        """
            the template.
        @param raise_when_empty: whether raise exception when the final sql is
            empty.
        @param pop_None: whether to considered None as empty value
        @return: (sql, param)
        """
        if not hasattr(self, "_deep_list"):
            self.build()
        cntx.update(self._const)
        if pop_None:
            # only preserve those not None values
            new_cntx = {}
            for k, v in cntx.iteritems():
                if v is not None:
                    new_cntx[k] = v
            cntx = new_cntx
        sql, param = self.traverse(self._deep_list, cntx)
        if raise_when_empty and not sql:
            raise Exception("Empty sql")
        return sql, tuple(param)

    def query(self, db, cntx, raise_when_empty=True, pop_None=True, **kw):
        sql, param = self(cntx, raise_when_empty, pop_None)
        logging.debug(sql)
        logging.debug(param)
        return db.query(sql, param, **kw)

    def modify(self, db, cntx, **kw):
        sql, param = self(cntx, **kw)
        return db.modify(sql, param)


if __name__ == "__main__":
    '''from datetime import datetime, timedelta
    b = datetime.now()
    e = b + timedelta(days=10)

    s = DynSql("""c1=$c1 { AND c2 IN $$c2 { AND c3=$c3}} { AND c4 > $c4 }""")
    print s({"c1": 1, "c2": None, "c3": "somecond"})
    print s({"c1": 1, "c2": (1, 2)})
    print s({"c1": 1, "c4": "abc"})
    print s({"c1": 1, "c2": (), "c3": "somecond"})

    s1 = DynSql("""st=$st [ AND id=$id { AND id1=$id1 } || AND ?time_type BETWEEN $begin AND $end || AND a=$none ] || 1=1""")
    print s1({"st": 1, "time_type": "fill_time", "begin": b, "end": e})
    print s1({"st": 1, "id": 3, "time_type": "fill_time", "begin": b, "end": e})
    print s1({"st": 1, "id": 3, "id1": 4})
    print s1({"st": 1})

    s2 = DynSql("""SELECT CONCAT($type, $mark)""", mark = '%')
    print s2({"type": 3})

    s3 = DynSql("""AND a = $a [{ AND b = $b } { AND e = $e } || {AND c = $c} {AND d = $d} ]""")
    print s3({'a': 3, 'c': 3, 'd': 7})

    s4 = DynSql("""{AND a = $e} {AND a = $e LEFT JOIN admin AS a ON a.id = s.id #a #b #c #!d}""")
    print s4({'e': 7, 'a': 1})
    print s4({'e': 7, 'a': 1, 'b': 3})
    print s4({'e': 7, 'a': 1, 'b': 3, 'c': 8})
    print s4({'e': 7, 'a': 1, 'b': 3, 'c': 8, 'd': 7})

    sql, params = s4({'e': 7, 'a': 1, 'b': 3, 'c': 8, 'd': 7})
    print sql
    print params'''
    s=DynSql("""select * from tbl_project where 1=1 { and id=$id}
            { and name=$name} { and info=$info} { and status=$status} {limit {$offset,} $row_cnt} ORDER BY id DESC""")
    sql=s({"offset":0,"row_cnt":10})
    print sql

