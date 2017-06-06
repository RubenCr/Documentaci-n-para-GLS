/*Extraído de:
 * Hampson, Dave. (2015). «FramesPerSecond». 
 * Driección URL: http://wiki.unity3d.com/wiki/index.php?title=FramesPerSecond.
 * Fecha de consulta: 25 de febrero de 2015*/

using UnityEngine;
using System.Collections;

public class FramesPerSecondDisplayScript : MonoBehaviour
{
    float deltaTime = 0.0f;
  

    void Update()
    {
        deltaTime += (Time.deltaTime - deltaTime) * 0.1f;
    }

    void OnGUI()
    {
        int w = Screen.width, h = Screen.height;

        GUIStyle style = new GUIStyle();

        Rect rect = new Rect(0, 0, w, h * 2 / 100);
        style.alignment = TextAnchor.UpperLeft;
        style.fontSize = h * 2 / 100;
        style.normal.textColor = new Color(1.0f, 1.0f, 1.0f, 1.0f);
        float msec = deltaTime * 1000.0f;
        float fps = 1.0f / deltaTime;
        string text = string.Format("{0:0.0} ms ({1:0.} fps)", msec, fps);
        GUI.Label(rect, text, style);
    }
}