/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
extern struct options_direct *ReadOptionsDirect(const mxArray *in);
extern mxArray *WriteOptionsDirect(const mxArray *in,struct options_direct *opts);
