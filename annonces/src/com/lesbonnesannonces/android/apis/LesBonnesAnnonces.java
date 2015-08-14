package com.lesbonnesannonces.android.apis;

import java.net.URI;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.StatusLine;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;


public class LesBonnesAnnonces extends Activity implements ScreenChanger, OnClickListener
{
	// Log tag
	private final static String LOG_TAG = "LesBonnesAnnonces";

	// Screen IDs
	private final static int SCREEN_SPLASH = 1;
	private final static int SCREEN_ADVERTISING = 2;
	private final static int SCREEN_WEBVIEW = 3;

	// HTTP URLs
	private final static String HOME_URL = "http://www.lesbonnesannonces.com/index_webapp.php?origine=androidapps";
	private final static String AD_IMAGE_URL = "http://www.lesbonnesannonces.com/pub/android.php?format=";
	private final static String AD_TARGET_URL = "http://www.lesbonnesannonces.com/pub/redirect.php"; 

	// Menu items
	private final static int MENU_CANCEL = 1;
	private final static int MENU_REFRESH = 2;
	private final static int MENU_QUIT = 3;

	private Thread downloadThread;


	// Webview principale
	private WebView webview;
	// Splash
	private View splashView;
	// Pub
	private ImageView adView;
	private Bitmap adBitmap;
	// Ecran en cours (= SCREEN_*)
	private int currentScreen;
	
	private ScreenAutomator screenAutomator;


	/** Called when the activity is first created. */
	@Override
	public void onCreate (Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Active l'indicateur de progression
		requestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);

		// Chargement vue
		setContentView(R.layout.main);
		setProgressBarIndeterminateVisibility(true);

		// Splash
		splashView = findViewById(R.id.splash);

		// Pub
		adView = (ImageView) findViewById(R.id.advertising);
		adView.setOnClickListener(this);

		// Webview
		webview = (WebView) findViewById(R.id.webview);
		webview.getSettings().setJavaScriptEnabled(true);
		webview.setWebViewClient(new WebViewClientLBA());
		webview.setWebChromeClient(new WebChromeClientLBA());

		currentScreen = SCREEN_SPLASH;
		screenAutomator = new ScreenAutomator(this);
		downloadAd();
	}

	@Override
	public boolean onKeyDown (int keyCode, KeyEvent event) {
		if ((keyCode == KeyEvent.KEYCODE_BACK) && webview.canGoBack()) {
			webview.goBack();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}
	
	public void onClick (View clickedView) {
		if (clickedView == adView) {
			Intent browser = new Intent(Intent.ACTION_VIEW, Uri.parse(AD_TARGET_URL));
			startActivity(browser);
			finish();
		}
	}

	
	/* ************************* */
	/*  NAVIGATION ENTRE ECRANS  */
	/* ************************* */ 

	public void onScreenChange (int screen) {
		if (currentScreen >= screen) {
			return;
		}
		currentScreen = screen;
		
		runOnUiThread(
				new Runnable()
				{
					public void run() {
						// Affiche Pub
						if (currentScreen == SCREEN_ADVERTISING) {
							setProgressBarIndeterminateVisibility(false);
							adView.setImageBitmap(adBitmap);
							adView.setVisibility(View.VISIBLE);
							splashView.setVisibility(View.GONE);
							return;
						}
						
						// Affiche webview
						if (currentScreen == SCREEN_WEBVIEW) {
							if (downloadThread != null) {
								downloadThread.interrupt();
								downloadThread = null;
							}
							setProgressBarIndeterminateVisibility(false);
							adBitmap = null;
							webview.setVisibility(View.VISIBLE);
							webview.requestFocus();  // Affiche les clicks sur les liens
							adView.setVisibility(View.GONE);
							adView.setImageBitmap(null);
							splashView.setVisibility(View.GONE);
							// Autorise basculement modes portrait/paysage
							setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
							return;
						}
					}
				});

	}
	
	static final class ScreenAutomator implements Handler.Callback
	{	
		private final static int MESSAGE_SPLASH_DURATION_REACHED = 1;
		private final static int MESSAGE_AD_DOWNLOAD_TIMEOUT_REACHED = 2;
		private final static int MESSAGE_AD_DURATION_REACHED = 3;
		
		private final static int SPLASH_DURATION = 3000;
		private final static int AD_DOWNLOAD_TIMEOUT = 5000;
		private final static int AD_DURATION = 3000;

		private ScreenChanger screenChanger;
		// 
		private Handler handler;
		// 
		private boolean splashDurationReached;
		private boolean adDownloadTimeoutReached;
		private boolean adDurationReached;
		private boolean adDownloadFinished;
		private boolean adAvailable;
		private boolean webviewLoaded;
		
		private int currentScreen;

		
		public ScreenAutomator (ScreenChanger screenChanger){
			this.screenChanger = screenChanger;
			currentScreen = SCREEN_SPLASH;
			handler = new Handler(this);
			handler.sendEmptyMessageDelayed(MESSAGE_SPLASH_DURATION_REACHED, SPLASH_DURATION);
			handler.sendEmptyMessageDelayed(MESSAGE_AD_DOWNLOAD_TIMEOUT_REACHED, AD_DOWNLOAD_TIMEOUT);
		}

		public final void adDownloadFinished (boolean success) {
			adDownloadFinished = true;
			adAvailable = success;
			process();
		}
		
		public final void webviewReady () {
			 webviewLoaded = true;
			 process();
		}

		public final boolean handleMessage (Message msg) {
			if (msg.what == MESSAGE_SPLASH_DURATION_REACHED) {
				splashDurationReached = true;
			}
			else if (msg.what == MESSAGE_AD_DOWNLOAD_TIMEOUT_REACHED) {
				if (!adDownloadFinished) {
					adDownloadTimeoutReached = true;
				}
			}
			else if (msg.what == MESSAGE_AD_DURATION_REACHED) {
				Log.i(LOG_TAG, "Ad duration reached");
				adDurationReached = true;
			}
			process();
			return true;
		}
		
		private synchronized final void process () {
			int nextScreen = -1;
			// Webview
			if (currentScreen < SCREEN_WEBVIEW) {
				if (webviewLoaded) {
					if (adDownloadTimeoutReached
							|| adDurationReached
							|| (splashDurationReached && adDownloadFinished && !adAvailable)) {
						nextScreen = SCREEN_WEBVIEW;
					}
				}
			}

			// Splash
			if ((nextScreen < 0) && (currentScreen < SCREEN_ADVERTISING)) {
				if (splashDurationReached && adDownloadFinished && adAvailable) {
					nextScreen = SCREEN_ADVERTISING;
					handler.sendEmptyMessageDelayed(MESSAGE_AD_DURATION_REACHED, AD_DURATION);
				}
			}
			
			if (nextScreen > 0) {
				currentScreen = nextScreen;
				screenChanger.onScreenChange(nextScreen);
			}
		}
	}


	/* ************************* */
	/*            MENU           */
	/* ************************* */

	//  A d�commenter pour activer le menu (ou seulement certains �l�ments)
    public boolean onCreateOptionsMenu(Menu menu) {
        menu.add(0, MENU_CANCEL, 0, R.string.menu_cancel).setIcon(R.drawable.ic_menu_block);
        menu.add(0, MENU_REFRESH, 0, R.string.menu_reload).setIcon(R.drawable.ic_menu_refresh);
        menu.add(0, MENU_QUIT, 0, R.string.menu_quit).setIcon(R.drawable.ic_menu_close_clear_cancel);
        return true;
    }

	public boolean onOptionsItemSelected(MenuItem item) {
		int menuItem = item.getItemId();

		if (menuItem == MENU_REFRESH) {
			webview.reload();
			return true;
		}

		if (menuItem == MENU_CANCEL) {
			webview.stopLoading();
			return true;
		}

		if (menuItem == MENU_QUIT) {
			finish();
			return true;
		}

		return false;
	}


	/* ************************* */
	/*            PUB            */
	/* ************************* */ 

	private final void downloadAd () {
		DisplayMetrics displayMetrics = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
		int width = displayMetrics.widthPixels;
		int height = displayMetrics.heightPixels;
		final String url = AD_IMAGE_URL + width + "x" + height;
		downloadThread = new Thread(
				new Runnable()
				{	
					public void run() {
						_downloadAd(url);
					}
				});
		downloadThread.start();
	}

	private final void _downloadAd (String url) {
		//Log.i(LOG_TAG, "ad url = " + url);
		byte[] data = getHttpContent(url);
		if (data != null) {
			adBitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
		}
		downloadThread = null;
		screenAutomator.adDownloadFinished(data != null);
		webview.loadUrl(HOME_URL);
	}

	public final static byte[] getHttpContent (String url) {
		try {
			DefaultHttpClient client = new DefaultHttpClient();
			HttpGet request = new HttpGet(new URI(url));
			HttpResponse response = client.execute(request);
			StatusLine status = response.getStatusLine();
			if (status.getStatusCode() == HttpStatus.SC_OK) {
				byte[] data = EntityUtils.toByteArray(response.getEntity());
				client.getConnectionManager().shutdown();
				return data;
			}
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}


	/* ************************* */
	/*    SOUS CLASSES WEBVIEW   */
	/* ************************* */ 

	class WebViewClientLBA extends WebViewClient
	{
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url)
		{
			if (url.startsWith("tel:")) {  // Intercepte les urls de t�l�phone
				//Log.i(LOG_TAG, "Lance le dialer : " + url);
				Intent intent = new Intent(Intent.ACTION_DIAL, Uri.parse(url));
				startActivity(intent);
				return true;
			}
			
			else if (url.startsWith("geo:")) {  // Intercepte les urls de geolocalisation (carte)
				Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
				startActivity(intent);
				return true;
			}

			return false;
		}

		@Override
		public void onPageStarted (WebView view, String url, Bitmap favicon) {
			super.onPageStarted(view, url, favicon);

			// Affiche indicateur de chargement
			setProgressBarIndeterminateVisibility(true);
		}

		@Override
		public void onPageFinished (WebView view, String url) {
			super.onPageFinished(view, url);

			// Supprime indicateur de chargement
			if (currentScreen == SCREEN_WEBVIEW) {
				setProgressBarIndeterminateVisibility(false);
			}
		}
	}

	class WebChromeClientLBA extends WebChromeClient
	{
		public final void onProgressChanged (WebView view, int newProgress) {
			// Accueil Webview charg�
			if ((currentScreen != SCREEN_WEBVIEW) && (newProgress > 80)) {
				Log.i(LOG_TAG, "Home page loaded");
				screenAutomator.webviewReady();
			}
		}
	}

}


interface ScreenChanger
{
	public void onScreenChange (int screen);
}