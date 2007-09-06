/*
 * Ext JS Library 1.1.1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */

Ext.data.SimpleStore=function(A){Ext.data.SimpleStore.superclass.constructor.call(this,{reader:new Ext.data.ArrayReader({id:A.id},Ext.data.Record.create(A.fields)),proxy:new Ext.data.MemoryProxy(A.data)});this.load()};Ext.extend(Ext.data.SimpleStore,Ext.data.Store);