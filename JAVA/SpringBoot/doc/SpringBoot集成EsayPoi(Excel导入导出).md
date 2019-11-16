### 1.导入jar包

```
    <!--EasyPoi导入导出-->
        <dependency>
            <groupId>cn.afterturn</groupId>
            <artifactId>easypoi-base</artifactId>
            <version>3.0.3</version>
        </dependency>
        <dependency>
            <groupId>cn.afterturn</groupId>
            <artifactId>easypoi-web</artifactId>
            <version>3.0.3</version> </dependency>
        <dependency>
            <groupId>cn.afterturn</groupId>
            <artifactId>easypoi-annotation</artifactId>
            <version>3.0.3</version>
        </dependency>
        <!-- 文件上传 -->

        <dependency>
            <groupId>commons-fileupload</groupId>
            <artifactId>commons-fileupload</artifactId>
            <version>1.3.1</version>
        </dependency>
```

### 2.导入工具类

```
package com.zzf.finals.utiles;

import cn.afterturn.easypoi.excel.ExcelExportUtil;
import cn.afterturn.easypoi.excel.ExcelImportUtil;
import cn.afterturn.easypoi.excel.entity.ExportParams;
import cn.afterturn.easypoi.excel.entity.ImportParams;
import cn.afterturn.easypoi.excel.entity.enmus.ExcelType;
import org.apache.commons.lang3.StringUtils;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

public class ExcelUtiles {
    public static void exportExcel(List<?> list, String title, String sheetName, Class<?> pojoClass,
                                   String fileName, boolean isCreateHeader, HttpServletResponse response){
        ExportParams exportParams = new ExportParams(title, sheetName);
        exportParams.setCreateHeadRows(isCreateHeader);
        defaultExport(list, pojoClass, fileName, response, exportParams);
    }

    public static void exportExcel(List<?> list, String title, String sheetName, Class<?> pojoClass,String fileName,
                                   HttpServletResponse response){
        defaultExport(list, pojoClass, fileName, response, new ExportParams(title, sheetName));
    }

    public static void exportExcel(List<Map<String, Object>> list, String fileName, HttpServletResponse response){
        defaultExport(list, fileName, response);
    }

    private static void defaultExport(List<?> list, Class<?> pojoClass, String fileName,
                                      HttpServletResponse response, ExportParams exportParams) {
        Workbook workbook = ExcelExportUtil.exportExcel(exportParams,pojoClass,list);
        if (workbook != null); downLoadExcel(fileName, response, workbook);
    }

    private static void downLoadExcel(String fileName, HttpServletResponse response, Workbook workbook) {
        try {
            response.setCharacterEncoding("UTF-8");
            response.setHeader("content-Type", "application/vnd.ms-excel");
            response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(fileName, "UTF-8"));
            workbook.write(response.getOutputStream());
        } catch (IOException e) {
            //throw new NormalException(e.getMessage());
        }
    }

    private static void defaultExport(List<Map<String, Object>> list, String fileName, HttpServletResponse response) {
        Workbook workbook = ExcelExportUtil.exportExcel(list, ExcelType.HSSF);
        if (workbook != null);
        downLoadExcel(fileName, response, workbook);
    }

    public static <T> List<T> importExcel(String filePath,Integer titleRows,Integer headerRows, Class<T> pojoClass){
        if (StringUtils.isBlank(filePath)){
            return null;
        }
        ImportParams params = new ImportParams();
        params.setTitleRows(titleRows);
        params.setHeadRows(headerRows);
        List<T> list = null;
        try {
            list = ExcelImportUtil.importExcel(new File(filePath), pojoClass, params);
        }catch (NoSuchElementException e){
            //throw new NormalException("模板不能为空");
        } catch (Exception e) {
            e.printStackTrace();
            //throw new NormalException(e.getMessage());
        } return list;
    }

        public static <T> List<T> importExcel(MultipartFile file, Integer titleRows, Integer headerRows, Class<T> pojoClass){
        if (file == null){ return null;
        }
        ImportParams params = new ImportParams();
        params.setTitleRows(titleRows);
        params.setHeadRows(headerRows);
        List<T> list = null;
        try {
            list = ExcelImportUtil.importExcel(file.getInputStream(), pojoClass, params);
        }catch (NoSuchElementException e){
           // throw new NormalException("excel文件不能为空");
        } catch (Exception e) {
            //throw new NormalException(e.getMessage());
            System.out.println(e.getMessage());
        }
        return list;
    }

}

```

### 3.编写实体映射类

```
package com.zzf.finals.entity;

import cn.afterturn.easypoi.excel.annotation.Excel;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "seckill")
public class DemoExcel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Excel(name = "id" ,orderNum = "0")
    private Long seckillId;

    @Column(name = "name")
    @Excel(name = "姓名" ,orderNum = "1")
    private String name;

    @Column(name = "number")
    @Excel(name = "数量" ,orderNum = "2")
    private int number;

    @Column(name = "start_time")
    @Excel(name = "开始日期" ,orderNum = "3",importFormat = "yyyy-MM-dd HH:mm:ss")//exportFormat = "yyyy-MM-dd HH:mm:ss")
    private Date startTime;

    @Column(name = "end_time")
    @Excel(name = "结束日期" ,orderNum = "4",importFormat = "yyyy-MM-dd HH:mm:ss")//exportFormat = "yyyy-MM-dd HH:mm:ss")
    private Date endTime;

    @Column(name = "create_time")
    @Excel(name = "创建日期" ,orderNum = "5",importFormat = "yyyy-MM-dd HH:mm:ss")//exportFormat = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    public Long getSeckillId() {
        return seckillId;
    }

    public void setSeckillId(Long seckillId) {
        this.seckillId = seckillId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public Date getStartTime() {
        return startTime;
    }

    public void setStartTime(Date startTime) {
        this.startTime = startTime;
    }

    public Date getEndTime() {
        return endTime;
    }

    public void setEndTime(Date endTime) {
        this.endTime = endTime;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    @Override
    public String toString() {
        return "DemoExcel{" +
                "seckillId=" + seckillId +
                ", name='" + name + '\'' +
                ", number=" + number +
                ", startTime=" + startTime +
                ", endTime=" + endTime +
                ", createTime=" + createTime +
                '}';
    }
}

```

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095859330.png)

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095856428.png)

 

### 4.控制器代码

```
package com.zzf.finals.controller;

import cn.afterturn.easypoi.excel.ExcelImportUtil;
import cn.afterturn.easypoi.excel.entity.ImportParams;
import cn.afterturn.easypoi.excel.entity.result.ExcelImportResult;
import cn.afterturn.easypoi.handler.inter.IExcelDataHandler;
import cn.afterturn.easypoi.util.PoiPublicUtil;
import com.zzf.finals.entity.DemoExcel;
import com.zzf.finals.repository.DemoExcelRepository;
import com.zzf.finals.service.DemoService;
import com.zzf.finals.utiles.ExcelUtiles;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/Excel")
public class ExcelController {

    @Autowired
    private DemoExcelRepository demoExcelRepository;

    @Autowired
    private DemoService demoService;

    @GetMapping("/export")
    public void export(HttpServletResponse response) {
        System.out.println(1);
//        模拟从数据库获取需要导出的数据
        List<DemoExcel> personList = demoExcelRepository.findAll();
//         导出操作
        ExcelUtiles.exportExcel(personList, "测试名", "什么名字", DemoExcel.class, "测试.xls", response);

    }

    @PostMapping("/importExcel2")
    public void importExcel2(@RequestParam("file") MultipartFile file) {
        ImportParams importParams = new ImportParams();
        // 数据处理
        importParams.setHeadRows(1);
        importParams.setTitleRows(1);

        // 需要验证
        importParams.setNeedVerfiy(true);

        try {
            ExcelImportResult<DemoExcel> result = ExcelImportUtil.importExcelMore(file.getInputStream(), DemoExcel.class,
                    importParams);

            List<DemoExcel> successList = result.getList();
            for (DemoExcel demoExcel : successList) {
              System.out.println(demoExcel);
            }
        } catch (IOException e) {
        } catch (Exception e) {
        }
    }
}




```

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095857915.png)

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095858544.png)

输入连接后如图所示。

导入后如：

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095854962.png)

最最最简单的导入导出就这么完成了。

 

### 修改自定义样式：

查看源码我发现他内部封装的是：

 

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095855812.png)所以我们只需要设置这个样式就行了如：

```
public class ShelterIExcelExportStyler extends ExcelExportStylerDefaultImpl implements IExcelExportStyler{

	
	
	public ShelterIExcelExportStyler(Workbook workbook) {
		super(workbook);
	}

    @Override
    public CellStyle getTitleStyle(short color) {
        CellStyle titleStyle = workbook.createCellStyle();
        titleStyle.setAlignment(CellStyle.ALIGN_CENTER);
        titleStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
        titleStyle.setWrapText(true);
        return titleStyle;
    }

    @Override
    public CellStyle stringSeptailStyle(Workbook workbook, boolean isWarp) {
        CellStyle style = workbook.createCellStyle();
        style.setAlignment(CellStyle.ALIGN_CENTER);
        style.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
        style.setDataFormat(STRING_FORMAT);
        if (isWarp) {
            style.setWrapText(true);
        }
        return style;
    }

    @Override
    public CellStyle getHeaderStyle(short color) {
        CellStyle titleStyle = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setFontHeightInPoints((short) 20);
        titleStyle.setFont(font);
        titleStyle.setAlignment(CellStyle.ALIGN_CENTER);
        titleStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
        return titleStyle;
    }

    @Override
    public CellStyle stringNoneStyle(Workbook workbook, boolean isWarp) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
//        font.setFontHeightInPoints((short) 15);
        style.setFont(font);
        style.setAlignment(CellStyle.ALIGN_CENTER);
        style.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
        style.setDataFormat(STRING_FORMAT);
        
        if (isWarp) {
            style.setWrapText(true);
        }
        return style;
    }


}
```

这里我只是简单的修改了他默认字体大小。如果要设置表格的宽度不可以在这里设置。

 

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095853629.png)

```
    private static void defaultExport(List<?> list, Class<?> pojoClass, String fileName,
                                      HttpServletResponse response, ExportParams exportParams, String sheetName) {
        Workbook workbook = ExcelExportUtil.exportExcel(exportParams,pojoClass,list);
        Sheet sheet=workbook.getSheet(sheetName);
//        sheet.CreateRow(0).Height = (short)(200*20);
       // sheet.createRow(0);
        sheet.getRow(0).setHeight((short)(50*20));
        sheet.getRow(1).setHeight((short)(30*20));
        if (workbook != null); downLoadExcel(fileName, response, workbook);
    }
```

他会调用ExportExcel返回一个Workbook对象，然后通过这个对象获取Sheet才能改变行的宽度千万不腰用CreateRow会覆盖。

 

有些人会在使用导入的时候出现只导入一条数据或者列缺少的情况，个人推荐可以使用步进指令去调试这段代码改成适用自己的”轮子“。我通过调试发现保存数据是这个方法：

```
	private <T> List<T> importExcel(Collection<T> result, Sheet sheet, Class<?> pojoClass, ImportParams params,
			Map<String, PictureData> pictures) throws Exception {
		List collection = new ArrayList();
		Map<String, ExcelImportEntity> excelParams = new HashMap<String, ExcelImportEntity>();
		List<ExcelCollectionParams> excelCollection = new ArrayList<ExcelCollectionParams>();
		String targetId = null;
		if (!Map.class.equals(pojoClass)) {
			Field[] fileds = PoiPublicUtil.getClassFields(pojoClass);
			ExcelTarget etarget = pojoClass.getAnnotation(ExcelTarget.class);
			if (etarget != null) {
				targetId = etarget.value();
			}
			getAllExcelField(targetId, fileds, excelParams, excelCollection, pojoClass, null, null);
		}
		Iterator<Row> rows = sheet.rowIterator();
		for (int j = 0; j < params.getTitleRows(); j++) {
			rows.next();
		}
		Map<Integer, String> titlemap = getTitleMap(rows, params, excelCollection);
		checkIsValidTemplate(titlemap, excelParams, params, excelCollection);
		Row row = null;
		Object object = null;
		String picId;
		int readRow = 0;
		// 跳过无效行
		for (int i = 0; i < params.getStartRows(); i++) {
			rows.next();
		}
		while (rows.hasNext()
				&& (row == null || sheet.getLastRowNum() - row.getRowNum() > params.getLastOfInvalidRow())) {
			if (params.getReadRows() > 0 && readRow > params.getReadRows()) {
				break;
			}
			row = rows.next();
			// Fix 如果row为无效行时候跳出
			if (sheet.getLastRowNum() - row.getRowNum() < params.getLastOfInvalidRow()) {
				break;
			}
			// 判断是集合元素还是不是集合元素,如果是就继续加入这个集合,不是就创建新的对象
			// keyIndex 如果为空就不处理,仍然处理这一行
			if (params.getKeyIndex() != null && !(row.getCell(params.getKeyIndex()) == null
					|| StringUtils.isEmpty(getKeyValue(row.getCell(params.getKeyIndex())))) && object != null) {

				for (ExcelCollectionParams param : excelCollection) {
					addListContinue(object, param, row, titlemap, targetId, pictures, params);
				}
			} else {
				object = PoiPublicUtil.createObject(pojoClass, targetId);
				try {
					// 标记为null的次数
					int count = 0;
					int sum = titlemap.size();
					for (int i = row.getFirstCellNum(); i <= sum; i++) {
						Cell cell = row.getCell(i);
						boolean flag = true;
						if (cell.getCellType() == HSSFCell.CELL_TYPE_BLANK) {
							count++;
							flag = false;
						}
						String titleString = (String) titlemap.get(i);
						if (excelParams.containsKey(titleString) || Map.class.equals(pojoClass)) {
							if (excelParams.get(titleString) != null && excelParams.get(titleString).getType() == 2) {
								picId = row.getRowNum() + "_" + i;
								saveImage(object, picId, excelParams, titleString, pictures, params);
							} else {
								if (saveFieldValue(params, object, cell, excelParams, titleString, row)) {
									if (flag)//只有当没有count++过才能添加。
										count++;
								}
							}
						}
					}

					for (ExcelCollectionParams param : excelCollection) {
						addListContinue(object, param, row, titlemap, targetId, pictures, params);
					}
					if (verifyingDataValidity(object, row, params, pojoClass)) {
						// count等于0或者
						if ((count == 0) || (count <= sum - 2))
							collection.add(object);
					} else {
						// 如果为null的次数小于5则添加
						// if (count!=0 || count < sum-3)
						failCollection.add(object);
					}
				} catch (ExcelImportException e) {
					LOGGER.error("excel import error , row num:{},obj:{}", readRow,
							ReflectionToStringBuilder.toString(object));
					if (!e.getType().equals(ExcelImportEnum.VERIFY_ERROR)) {
						throw new ExcelImportException(e.getType(), e);
					}
				} catch (Exception e) {
					LOGGER.error("excel import error , row num:{},obj:{}", readRow,
							ReflectionToStringBuilder.toString(object));
					throw new RuntimeException(e);
				}
			}
			readRow++;
		}
		return collection;
	}
```

这个类是![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095854310.png)

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095902018.png)

修改的位置在这里，我通过修改这段代码使其强制进入else中可以拿到所有数据，然后判断null的次数选择是否添加。

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095857074.png)

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528095901315.png)

适用自己的轮子才是最好的轮子……

