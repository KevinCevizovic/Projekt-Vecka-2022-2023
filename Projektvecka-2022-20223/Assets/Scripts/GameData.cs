using UnityEngine;

public static class GameData
{
    public static float musicVolume, soundEffectVolume;

    public static void LoadSettings()
    {
        musicVolume = PlayerPrefs.GetFloat("musicVolume", 1f);
        soundEffectVolume = PlayerPrefs.GetFloat("soundEffectVolume", 1f);

        Debug.Log("Settings loaded");
    }

    public static void SaveSettings()
    {
        PlayerPrefs.SetFloat("musicVolume", musicVolume);
        PlayerPrefs.SetFloat("soundEffectVolume", soundEffectVolume);

        PlayerPrefs.Save();

        Debug.Log("Settings saved");
    }
}