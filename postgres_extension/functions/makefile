# makefile for writing postgresql extension in C
MODULE_big = functions
OBJS = functions.o
EXTENSION = functions
DATA = functions--1.0.sql
PG_CFLAGS = -std=c99

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
