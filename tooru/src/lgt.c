/*
 * 2019.12.4
 * Project Tooru
 * gametracer lua mod
 *
 */

#include "gt/gt.h"
#include "tooru.h"
#include <stdlib.h>
#include <stdio.h>

static int gnm_ex(lua_State *L)
{
    int pn;
    int *lan;
    int i, j;
    int good, ret;
    int total, eq_l;
    char msg[100];
    double *payoff_mtx;
    double *eqs;
    int eq_num;
    long long tmp;

    tmp = luaL_checkinteger(L, 1);
    if (tmp > INT_MAX)
    {
        lua_pushnil(L);
        lua_pushliteral(L, "gametracer only support i32 int");
        return 2;
    }
    pn = (int)tmp;
    luaL_argcheck(L, pn > 1, 1, "invalid players number");
    luaL_checktype(L, 2, LUA_TTABLE);
    if (pn != luaL_len(L, 2))
        luaL_error(L, "lgt error: players number not eq with players actions list length");
    lan = (int *)malloc(pn * sizeof(int));
    total = pn;
    eq_l = 0;
    for (i = 0; i < pn; i++)
    {
        lua_geti(L, 2, i + 1);
        tmp = lua_tointegerx(L, -1, &good);
        if (tmp > INT_MAX)
        {
            free(lan);
            lua_pushnil(L);
            lua_pushliteral(L, "gametracer only support i32 int");
            return 2;
        }
        lan[i] = (int)tmp;
        if (!good || lan[i] < 1)
        {
            sprintf(msg, "need a list of +int, but index %d is not", i + 1);
            luaL_argerror(L, 2, msg);
        }
        lua_pop(L, 1);
        total *= lan[i];
        eq_l += lan[i];
    }
    luaL_checktype(L, 3, LUA_TTABLE);
    if (total != luaL_len(L, 3))
        luaL_error(L, "lgt error: payoff mtx's length is invalid with players' info");
    payoff_mtx = (double *)malloc(sizeof(double) * total);
    for (i = 0; i < total; i++)
    {
        lua_geti(L, 3, i + 1);
        payoff_mtx[i] = lua_tonumberx(L, -1, &good);
        if (!good)
        {
            sprintf(msg, "need a list of number, but index %d is not", i + 1);
            luaL_argerror(L, 3, msg);
        }
        lua_pop(L, 1);
    }

    eqs = gt_gnm_new(pn, lan, payoff_mtx, &eq_num);
    if (eq_num < 0)
    {
        lua_pushnil(L);
        lua_pushstring(L, gt_error(eq_num));
        ret = 2;
    }
    else
    {
        lua_createtable(L, eq_num, 0);
        for (i = 0; i < eq_num; i++)
        {
            lua_createtable(L, eq_l, 0);
            for (j = 0; j < eq_l; j++)
            {
                lua_pushnumber(L, eqs[i * eq_l + j]);
                lua_seti(L, -2, j + 1);
            }
            lua_seti(L, -2, i + 1);
        }
        ret = 1;
    }

    free(eqs);
    free(payoff_mtx);
    free(lan);
    return ret;
}

static int ipa_ex(lua_State *L)
{
    return 0;
}

static const luaL_Reg LGT[] = {
    {"gnm", gnm_ex},
    {"ipa", ipa_ex},
    {NULL, NULL}};

TOORU_EXPORT int luaopen_lgt(lua_State *L)
{
    luaL_newlib(L, LGT);
    return 1;
}