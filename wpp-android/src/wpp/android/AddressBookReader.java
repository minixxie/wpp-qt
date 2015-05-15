package wpp.android;

import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.ContentResolver;
import android.database.Cursor;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds;

public class AddressBookReader
{
        public static String fetchAddressBook(Context context)
	{
		//return "{\"test\":\"Hello World\"}";
                ContentResolver cr = context.getContentResolver();

                /**
                 * get phone numbers
                 */
                HashMap<String,ArrayList<String>> hashMap = new HashMap<String,ArrayList<String>>();
                Cursor phone = cr.query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                         new String[] {
                         CommonDataKinds.Phone.CONTACT_ID,
                         CommonDataKinds.Phone.DISPLAY_NAME,
                         CommonDataKinds.Phone.TYPE,
                         CommonDataKinds.Phone.LABEL,
                         CommonDataKinds.Phone.NUMBER,
                         CommonDataKinds.Phone.DATA1
                         //CommonDataKinds.StructuredPostal.DATA3,
                         },
                         null, null, null);
                while (phone.moveToNext()) {
                     String contactId = phone.getString(phone.getColumnIndex(CommonDataKinds.Phone.CONTACT_ID));
                     String displayName = phone.getString(phone.getColumnIndex(CommonDataKinds.Phone.DISPLAY_NAME));
                     String type = phone.getString(phone.getColumnIndex(CommonDataKinds.Phone.TYPE));
                     String label = phone.getString(phone.getColumnIndex(CommonDataKinds.Phone.LABEL));
                     String PhoneNumber = phone.getString(phone.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
                     String address = phone.getString(phone.getColumnIndex(CommonDataKinds.Phone.DATA1));

                     ArrayList<String> ad = hashMap.get(contactId);
                     if(ad == null){
                             ad = new ArrayList<String>();
                             ad.add(displayName);
                             PhoneNumber = "{'t':"+type+", 'l':"+(label==null?"null":"\""+label+"\"")+", 'p': '"+PhoneNumber+"'}";
                             ad.add(PhoneNumber);
                             //ad.add(address);

                             hashMap.put(contactId, ad);
                     }
                     else{
                             PhoneNumber = "{'t':"+type+", 'l':"+(label==null?"null":"\""+label+"\"")+", 'p': '"+PhoneNumber+"'}";
                             ad.add(PhoneNumber);
                     }

             }
             phone.close();// this is important

             /**
              * get emails
              */
             final String[] PROJECTION = new String[] {
                 ContactsContract.CommonDataKinds.Email.CONTACT_ID,
                 ContactsContract.Contacts.DISPLAY_NAME,
                 ContactsContract.CommonDataKinds.Email.DATA,
                 ContactsContract.CommonDataKinds.Email.TYPE,
                 ContactsContract.CommonDataKinds.Email.LABEL
             };

             HashMap<String,JSONArray> hashMap2 = new HashMap<String,JSONArray>();
             Cursor cursor = cr.query(ContactsContract.CommonDataKinds.Email.CONTENT_URI, PROJECTION, null, null, null);
             if (cursor != null) {
                 try {
                     final int contactIdIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.CONTACT_ID);
                     final int displayNameIndex = cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME);
                     final int emailIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA);
                     final int typeIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.TYPE);
                     final int labelIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.LABEL);
                     String contactId;
                     String displayName, Email, label, type;
                     while (cursor.moveToNext()) {
                         contactId = cursor.getString(contactIdIndex);
                         displayName = cursor.getString(displayNameIndex);
                         Email = cursor.getString(emailIndex);
                         type = cursor.getString(typeIndex);
                         label = cursor.getString(labelIndex);

                         JSONArray ad = hashMap2.get(contactId);
                             if(ad == null){
                                     ad = new JSONArray();
                                     //ad.add(displayName);
                                     //Email = "{'t':'"+type+"', 'l': '"+label+"', 'e': '"+Email+"'}";
                                     JSONObject email;
                                                     try {
                                                             email = new JSONObject("{'t':"+type+", 'l':"+(label==null?"null":"\""+label+"\"")+", 'p': '"+Email+"'}");
                                                             ad.put(email);
                                                     } catch (JSONException e) {
                                                             e.printStackTrace();
                                                     }

                                     //ad.add(address);

                                     hashMap2.put(contactId, ad);
                             }
                             else{
                                     //Email = "{'t':'"+type+"', 'l': '"+label+"', 'e': '"+Email+"'}";
                                     JSONObject email;
                                                     try {
                                                             email = new JSONObject("{'t':"+type+", 'l':"+(label==null?"null":"\""+label+"\"")+", 'p': '"+Email+"'}");
                                                             ad.put(email);
                                                     } catch (JSONException e) {
                                                             e.printStackTrace();
                                                     }

                             }
                     }
                 } finally {
                     cursor.close();
                 }
             }

             /**
              * 查询family name和last name
              */
             String whereName = ContactsContract.Data.MIMETYPE + " = ?";
             String[] whereNameParams = new String[] { ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE };
             HashMap<String,ArrayList<String>> hashMap3 = new HashMap<String,ArrayList<String>>();
             Cursor nameCur = cr.query(ContactsContract.Data.CONTENT_URI, null, whereName, whereNameParams, ContactsContract.CommonDataKinds.StructuredName.GIVEN_NAME);
             while (nameCur.moveToNext()) {
                     String contactId = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.CONTACT_ID));
                 String given = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.GIVEN_NAME));
                 String family = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.FAMILY_NAME));
                 String display = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME));
     //            Log.d("given===>", given!=null?given:"");
     //            Log.d("family===>", family!=null?family:"");
     //            Log.d("display===>", display!=null?display:"");

                 ArrayList<String> ad = hashMap3.get(contactId);
                 if(ad == null){
                             ad = new ArrayList<String>();
                             ad.add(given);
                             ad.add(family);

                             hashMap3.put(contactId, ad);
                     }
                     else{

                     }
             }
             nameCur.close();


             JSONArray returnJSON = new JSONArray();
             ArrayList<String> tmpList;
             String tmpStr = "";
             int k;
             Iterator iter = hashMap.entrySet().iterator();
             while (iter.hasNext()) {
                     HashMap.Entry entry = (HashMap.Entry) iter.next();
                 Object key = entry.getKey();
                 Object val = entry.getValue();

                 tmpList = (ArrayList) val;
                 tmpStr = "";
                 for(k = 1; k < tmpList.size(); k++){
                     tmpStr = tmpStr + tmpList.get(k) + ',' ;
                 }

                 JSONArray pArray = new JSONArray();;

                 for(k = 1; k < tmpList.size(); k++){
                     try {
                                             JSONObject p = new JSONObject(tmpList.get(k));
                                             pArray.put(p);
                                     } catch (JSONException e) {
                                             e.printStackTrace();
                                     }

                 }

     //            HashMap<String, String> tmpMap = new HashMap<String, String>();
     //            tmpMap.put("name", tmpList.get(0));
     //            tmpMap.put("phone", tmpStr);

     //            items.add(tmpMap);

				if ( hashMap3.get(key) != null )
				{
					JSONObject obj = new JSONObject();
					try {
						obj.put("fn", hashMap3.get(key).get(0));
						obj.put("ln", hashMap3.get(key).get(1));
						obj.put("p", pArray);
						obj.put("e", hashMap2.get(key));

						returnJSON.put(obj);

					} catch (JSONException e) {
						e.printStackTrace();
					}
				}
             }

             Log.d("returnJSON===>", returnJSON.toString());
             String result = returnJSON.toString();
		Log.d("json-length:", ""+result.length() );
		return result;
	}

}
