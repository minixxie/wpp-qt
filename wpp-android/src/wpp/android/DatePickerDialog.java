package wpp.android;

//import android.app.DatePickerDialog;
import java.util.Calendar;
import java.util.TimeZone;
import android.content.Context;
import android.app.Activity;
import android.widget.DatePicker;
import android.app.DatePickerDialog.OnDateSetListener;
import android.content.DialogInterface;

import android.util.Log;
import android.os.Looper;

import android.app.AlertDialog;
import android.widget.LinearLayout;
import android.widget.DatePicker;
import android.widget.TimePicker;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import android.os.Handler;
import android.os.Message;

public class DatePickerDialog
{
	/*private static class WppDatePickerDialog extends android.app.DatePickerDialog
	{
		WppDatePickerDialog(Context context)
		{

		}

	}*/

	public static String show2(Activity activity)
	{
		Log.e("DatePickerDialog","show()...");
		return "show!";
	}

	public static class DateTimePickerDialog extends AlertDialog
	{
		public DateTimePickerDialog(Context context, String initDateISO8601, String timezoneId, final long qmlDateTimePickerPtr)
		{
			super(context);

			Log.e("DatePickerDialog","timezoneId=" + timezoneId);
			final TimeZone tz = TimeZone.getTimeZone( timezoneId );


			Log.e("ClickOK", "timezone=" + tz);
			final Calendar cal = Calendar.getInstance(tz);

			//Date initDate = ISO8601DateParser.parse( initDateISO8601 );

			//DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'");
			//df.setTimeZone( TimeZone.getTimeZone("UTC") );
			Log.e("ClickOK", "initDateISO8601=" + initDateISO8601);
			Date initDate = null;
			try {
				initDate = ISO8601DateParser.parse( initDateISO8601 );
				//initDate = df.parse( initDateISO8601 /*.replace("Z", "+0000")*/ );
				//initDate = javax.xml.bind.DatatypeConverter.parseDateTime( initDateISO8601 ).getTime();
			}
			catch ( ParseException e )
			{
				Log.e("ClickOK", "exception:" + e);
				Log.e("ClickOK", "initDate=new Date()");
				initDate = new Date();
			}

			Log.e("ClickOK", "initDate=" + initDate);
			cal.setTime(initDate);
			Log.e("ClickOK", "cal=" + cal);

			final int year = cal.get(Calendar.YEAR);
			final int month = cal.get(Calendar.MONTH);
			final int day = cal.get(Calendar.DAY_OF_MONTH);
			final int hour = cal.get(Calendar.HOUR_OF_DAY);
			final int min = cal.get(Calendar.MINUTE);
			final int sec = cal.get(Calendar.SECOND);
			//final StringBuffer iso8601 = new StringBuffer();
			Log.e("ClickOK", "cal(year,month,day)=" + year + "/" + month + "/" + day + " " + hour + ":" + min + ":" + sec);


                        this.setTitle(R.string.date_picker_title);
			LinearLayout layout = new LinearLayout(context);

			final DatePicker datePicker = new DatePicker(context);
			int currentapiVersion = android.os.Build.VERSION.SDK_INT;
			if (currentapiVersion >= 11)
			{
				datePicker.setCalendarViewShown(false);
				datePicker.setSpinnersShown(true);

				  /*try
				  {
					  Method m = datePicker.getClass().getMethod("setCalendarViewShown", boolean.class);
					  m.invoke(datePicker, false);
					  Method m2 = datePicker.getClass().getMethod("setSpinnersShown", boolean.class);
					  m2.invoke(datePicker, true);
				  }
				  catch (Exception e) {} // eat exception in our case
					  */
			}
			//datePicker.setCalendarViewShown(false);
			//datePicker.setSpinnersShown(true);
			datePicker.updateDate(year, month, day);

			final TimePicker timePicker = new TimePicker(context);
			timePicker.setCurrentHour(new Integer(hour));
			timePicker.setCurrentMinute(new Integer(min));

			layout.setOrientation(LinearLayout.VERTICAL);
			layout.addView(datePicker);
			layout.addView(timePicker);
			this.setView(layout);

			final AlertDialog alertDialog = this;
                        alertDialog.setButton(DialogInterface.BUTTON_NEGATIVE, context.getString(R.string.cancel), new DialogInterface.OnClickListener() {

				@Override
				public void onClick(DialogInterface dialog, int which) {
					alertDialog.hide();
					dialog.cancel();
					//myLooper.quit();
				}
			});

                        alertDialog.setButton(DialogInterface.BUTTON_POSITIVE, context.getString(R.string.done), new DialogInterface.OnClickListener() {

				@Override
				public void onClick(DialogInterface dialog, int which) {
					alertDialog.hide();
					dialog.dismiss();
					int year = datePicker.getYear();
					int month = datePicker.getMonth();
					int day = datePicker.getDayOfMonth();
					Log.e("ClickOK", "date selected=" + year + "/" + (month+1) + "/" + day);
					int hour = timePicker.getCurrentHour().intValue();
					int min = timePicker.getCurrentMinute().intValue();
					Log.e("ClickOK", "time selected=" + hour + ":" + min);

					cal.set(year, month, day, hour, min, 0);
					Date date = cal.getTime();
					long time = cal.getTimeInMillis();
					Log.e("ClickOK", "time(unix)=" + time);

					//DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'");
					Log.e("ClickOK", "timezone=" + tz);
					//df.setTimeZone( TimeZone.getTimeZone("UTC") );
					//iso8601.delete(0, iso8601.length());
					//iso8601.append( ISO8601DateParser.toString(date) );

					String iso8601 = ISO8601DateParser.toString(date);
					Log.e("ClickOK", "iso8601=" + iso8601);

					DatePickerDialog.dateSelected( iso8601, qmlDateTimePickerPtr );

					//String name = etInput.getText().toString();
					//Toast.makeText(getBaseContext(), name, Toast.LENGTH_SHORT).show();
					//myLooper.quit();
				}
			});

			/*android.app.DatePickerDialog dialog = new android.app.DatePickerDialog(
				context,
				new android.app.DatePickerDialog.OnDateSetListener(){
					@Override
					public void onDateSet(DatePicker view, int year, int monthOfYear,int dayOfMonth)
					{
						//tv.setText("您设置了日期："+year+"年"+(monthOfYear+1)+"月"+dayOfMonth+"日");
						//dpd.dismiss();
						//Looper.quitSafely();
					}
				},
				year, month, day
			);*/
			/*{
				@Override
				void onClick(DialogInterface dialog, int which)
				{
					Log.e("onClick","date picker onclick...");
					if ( which == BUTTON_POSITIVE )
					{
						Log.e("onClick","date picker onclick...OK");
					}
					else if ( which == BUTTON_NEGATIVE )
					{
						Log.e("onClick","date picker onclick...Cancel");
					}

				}
			};*/
			alertDialog.setOnDismissListener(
				new DialogInterface.OnDismissListener()
				{
					public void onDismiss(DialogInterface dialog)
					{
						Log.e("onDismiss","date picker dismiss...");
						alertDialog.hide();
						//myLooper.quit();
						//datePickerDialog_visible=false;  //indicate dialog is cancelled/gone
					}
				}
			);

		}

	}


	public static native void dateSelected(String iso8601, long qmlDateTimePickerPtr);


	public static String show(Activity activity, final String initDateISO8601, final String timezoneId, final long qmlDateTimePickerPtr )
	{
		Log.e("DatePickerDialog","show()...");

		if ( Looper.myLooper() == Looper.getMainLooper() )
		{
			Log.e("DatePickerDialog","This is the main looper!");
		}
		else
		{
			Log.e("DatePickerDialog","This is NOT the main looper!");
		}



		//Looper.prepare();
		//final Looper myLooper = Looper.myLooper();

		final Context context = activity;

		//Handler dialogHandler = new Handler(){
			//public void handleMessage(Message msg)
			//{

			//}
		//};

		activity.runOnUiThread(new Runnable() {
			public void run()
			{
				DateTimePickerDialog alertDialog = new DateTimePickerDialog(context, initDateISO8601, timezoneId, qmlDateTimePickerPtr);
				alertDialog.show();

			}
		});

		//dialogHandler.sendMessage(Message.obtain());

		//Looper.loop();
		return "";
	}

}
