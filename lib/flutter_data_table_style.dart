/*
 * Created by 崔宝印 on 2020/7/23.
 * email: cuibaoyin3@jd.com
 * description: 
 */
import 'package:flutter/material.dart';

class DQDataTableStyle {
	final Color splitLineColor; //表格间分割线颜色
	final double splitLineWidth; //表格间分割线宽度

	final double contentCellWidth; //内容宽度
	final double contentCellHeight; //内容高度
	final Color contentColor; //表格，背景色

	final double rowTitleWidth; //行标题的宽度，高度取决于 行内容 高度
	final Color rowTitleColor; //行表题，背景色

	final double columnTitleHeight; //列表题高度，宽度取决于 列内容 宽度
	final Color columnTitleColor; //列表题，背景色

	const DQDataTableStyle({
		this.splitLineColor = const Color(0xFFDDDDDD),
		this.splitLineWidth = 0.5,
		this.contentCellWidth = 77.0,
		this.contentCellHeight = 50.0,
		this.contentColor = Colors.white,
		this.rowTitleWidth = 85.0,
		this.rowTitleColor = const Color(0xFFF2F2F2),
		this.columnTitleHeight = 50.0,
		this.columnTitleColor = const Color(0xFFF2F2F2),
	});

	static const DQDataTableStyle base = DQDataTableStyle();
}