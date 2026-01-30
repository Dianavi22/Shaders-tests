using System.Collections;
using UnityEditor.Rendering.LookDev;
using UnityEngine;

public class CameraShake : MonoBehaviour
{
    [Header("Target")]
    [SerializeField] private Transform target;

    private Vector3 originalLocalPos;
    private Coroutine shakeRoutine;

    public bool shake = false;
    public bool shakeBase = false;

    private void Awake()
    {
        if (!target) target = transform;
        originalLocalPos = target.localPosition;
    }

    private void Update()
    {
        if (shake)
        {
            ShakeSmooth(0.5f, 0.6f);
            shake = false;
        }


        if (shakeBase)
        {
            ShakeBasic(0.5f, 0.6f);
            shakeBase = false;
        }
    }

    #region PUBLIC API

    // ?? BASIQUE (Random brut)
    public void ShakeBasic(float duration, float strength)
    {
        StartShake(BasicShake(duration, strength));
    }

    // ?? SMOOTH (Perlin Noise)
    public void ShakeSmooth(float duration, float strength, float frequency = 20f)
    {
        StartShake(PerlinShake(duration, strength, frequency));
    }

    #endregion

    void StartShake(IEnumerator routine)
    {
        if (shakeRoutine != null)
            StopCoroutine(shakeRoutine);

        shakeRoutine = StartCoroutine(routine);
    }

    #region SHAKES

    IEnumerator BasicShake(float duration, float strength)
    {
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float damper = 1f - (elapsed / duration);

            Vector3 offset = Random.insideUnitSphere * strength * damper;
            target.localPosition = originalLocalPos + offset;

            yield return null;
        }

        target.localPosition = originalLocalPos;
    }

    IEnumerator PerlinShake(float duration, float strength, float frequency)
    {
        float elapsed = 0f;
        float seed = Random.Range(0f, 100f);

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float damper = 1f - (elapsed / duration);

            float x = (Mathf.PerlinNoise(seed, Time.time * frequency) - 0.5f) * 2;
            float y = (Mathf.PerlinNoise(seed + 1, Time.time * frequency) - 0.5f) * 2;

            Vector3 offset = new Vector3(x, y, 0) * strength * damper;
            target.localPosition = originalLocalPos + offset;

            yield return null;
        }

        target.localPosition = originalLocalPos;
    }

    #endregion
}
